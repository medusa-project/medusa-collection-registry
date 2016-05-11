class CfsDirectoriesController < ApplicationController

  before_action :public_view_enabled?, only: [:public]
  before_action :require_medusa_user, except: [:show, :public, :show_tree]
  before_action :require_medusa_user_or_basic_auth, only: [:show, :show_tree]
  before_action :find_directory, only: [:events, :create_fits_for_tree, :export, :export_tree, :fixity_check, :show_tree]
  layout 'public', only: [:public]

  def show
    @directory = CfsDirectory.includes(:subdirectories, :cfs_files).find(params[:id])
    @accrual = Accrual.new(cfs_directory: @directory).decorate
    @breadcrumbable = @directory
    @file_group = @directory.file_group
    respond_to do |format|
      format.html do
        redirect_to @file_group and return if @directory.root? and @file_group.present?
      end
      format.json
    end
  end

  def public
    @directory = CfsDirectory.includes(:subdirectories, :cfs_files).find(params[:id])
    redirect_to unauthorized_path unless @directory.public?
    @file_group = @directory.file_group
    @collection = @file_group.collection
    @public_object = @directory
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
        @csv_options = {col_sep: "\t"}
        response.headers['Content-Type'] = 'text/tab-separated-values'
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
    @eventable = @directory
    @events = @eventable.cascaded_events
  end

  protected

  def find_directory
    @directory = CfsDirectory.find(params[:id])
    @breadcrumbable = @directory
  end

end