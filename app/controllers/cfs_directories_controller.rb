class CfsDirectoriesController < ApplicationController

  before_action :require_medusa_user, except: [:show, :show_tree]
  before_action :require_medusa_user_or_basic_auth, only: [:show, :show_tree]
  before_action :find_directory, only: [:events, :create_fits_for_tree, :export, :export_tree, :fixity_check, :show_tree]
  before_action :find_directory_with_includes, only: [:show]

  def show
    @accrual = Accrual.new(cfs_directory: @directory).decorate
    @file_group = @directory.file_group
    respond_to do |format|
      format.html do
        redirect_to @file_group and return if @directory.root? and @file_group.present?
      end
      format.json
    end
  end

  def create_fits_for_tree
    authorize! :create_cfs_fits, @directory.file_group
    Job::FitsDirectoryTree.create_for(@directory)
    flash[:notice] = "Scheduling FITS creation for /#{@directory.relative_path}"
    redirect_to @directory
  end

  def export
    authorize! :export, @directory.file_group
    Downloader::Request.create_for(@directory, current_user, recursive: false)
  end

  def export_tree
    authorize! :export, @directory.file_group
    Downloader::Request.create_for(@directory, current_user, recursive: true)
  end

  def show_tree
    respond_to do |format|
      format.tsv do
        @filename = "#{@directory.path}.tsv"
        @output_encoding = 'UTF-8'
        @csv_options = {col_sep: "\t", row_sep: "\r\n"}
        response.headers['Content-Type'] = 'text/tab-separated-values'
      end
      format.json do
        render json: directory_tree_as_hashes(@directory)
      end
    end
  end

  def fixity_check
    @file_group = @directory.file_group
    authorize! :update, @file_group
    @directory.transaction do
      @directory.events.create(key: 'fixity_check_scheduled', date: Date.today, actor_email: current_user.email)
      if Job::FixityCheck.find_by(fixity_checkable: @directory)
        flash[:notice] = 'Fixity check already scheduled for this cfs directory'
      else
        Job::FixityCheck.create_for(@directory, @directory, current_user)
        flash[:notice] = 'Fixity check scheduled'
      end
    end
    redirect_to @directory
  end

  def events
    @helper = SearchHelper::TableEvent.new(params: params, cascaded_eventable: @directory)
    respond_to do |format|
      format.html
      format.json do
        render json: @helper.json_response
      end
    end
  end

  protected

  def find_directory
    @directory = CfsDirectory.find(params[:id])
    @breadcrumbable = @directory
  end

  def find_directory_with_includes
    @directory = CfsDirectory.includes(:subdirectories, {cfs_files: [:content_type, :file_extension]}).find(params[:id])
    @breadcrumbable = @directory
  end

  def directory_tree_as_hashes(directory)
    cfs_directory_ids = directory.recursive_subdirectory_ids
    directories = CfsDirectory.where(id: cfs_directory_ids).includes(cfs_files: [:medusa_uuid, :content_type]).includes(:medusa_uuid)
    directory_hashes = directories.collect { |d| [d.id, directory_to_hash(d)] }.to_h
    #make the tree
    directory_hashes.each do |id, hash|
      unless id == directory.id
        parent_hash = directory_hashes[hash[:parent_id]]
        parent_hash[:subdirectories] ||= Array.new
        parent_hash[:subdirectories] << hash
      end
    end
    #Add this now for efficiency
    add_relative_path_information(directory.relative_path, directory_hashes[directory.id])
    #remove parent information, which was just for us to use in construction
    directory_hashes.each do |h|
      %i(parent_id parent_type).each {|key| h.delete(key)}
    end
    return directory_hashes[directory.id]
  end

  def directory_to_hash(directory)
    Hash.new.tap do |h|
      h[:id] = directory.id
      h[:uuid] = directory.uuid
      h[:name] = directory.path
      h[:parent_id] = directory.parent_id
      h[:parent_type] = directory.parent_type
      h[:files] = directory.cfs_files.collect do |cfs_file|
        Hash.new.tap do |file_hash|
          file_hash[:id] = cfs_file.id
          file_hash[:uuid] = cfs_file.uuid
          file_hash[:name] = cfs_file.name
          file_hash[:content_type] = cfs_file.content_type_name
          file_hash[:md5_sum] = cfs_file.md5_sum
          file_hash[:size] = cfs_file.size.to_i
          file_hash[:mtime] = cfs_file.mtime
        end
      end
    end
  end

  def add_relative_path_information(root_path, root_hash)
    root_hash[:relative_pathname] = root_path
    pending_hashes = [root_hash]
    while current_hash = pending_hashes.pop
      if current_hash[:subdirectories].present?
        current_hash[:subdirectories].each do |subdirectory|
          subdirectory[:relative_pathname] = File.join(current_hash[:relative_pathname], subdirectory[:name])
          pending_hashes.push(subdirectory)
        end
      end
      current_hash[:files].each do |file|
        file[:relative_pathname] = File.join(current_hash[:relative_pathname], file[:name])
      end
    end
  end

end