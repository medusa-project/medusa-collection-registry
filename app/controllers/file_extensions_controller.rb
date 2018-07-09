class FileExtensionsController < ApplicationController
  before_action :require_medusa_user
  before_action :find_file_extension

  def cfs_files
    @repository_id = params[:repository_id]
    @virtual_repository_id = params[:virtual_repository_id]
    @collection_id = params[:collection_id]
    @cfs_files = cfs_files_query.includes(cfs_directory: {root_cfs_directory: {parent: :collection}})
  end

  def random_cfs_file
    redirect_to @file_extension.random_cfs_file(params.slice(:repository_id, :virtual_repository_id, :collection_id))
  end

  def download_batch
    cfs_files_query.each do |cfs_file|
      authorize! :read, cfs_file
    end
    create_download_package(cfs_files_query)
  end

  protected

  def find_file_extension
    @file_extension = FileExtension.find(params[:id])
  end

  def create_download_package(cfs_files)
    Downloader::Request.create_for_file_list(cfs_files, current_user)
  end

  def cfs_files_query
    if @repository_id
      @file_extension.cfs_files.
          joins(cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}).
          where('collections.repository_id = ?', @repository_id).order('cfs_files.name asc')
    elsif @virtual_repository_id
      @virtual_repository = VirtualRepository.find(@virtual_repository_id)
      @file_extension.cfs_files.
          joins(cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}).
          where('collections.id': @virtual_repository.collection_ids).order('cfs_files.name asc')
    elsif @collection_id
      @file_extension.cfs_files.
          joins(cfs_directory: {root_cfs_directory: :parent_file_group}).
          where('file_groups.collection_id = ?', @collection_id).order('cfs_files.name asc')
    else
      @file_extension.cfs_files.order('name asc')
    end.page(params[:page]).per_page(params[:per_page] || 25)
  end


end