class CfsDirectoriesController < ApplicationController

  before_action :public_view_enabled?, only: [:public]
  before_action :require_logged_in, except: [:show, :public]
  before_action :require_logged_in_or_basic_auth, only: [:show]
  before_action :find_directory, only: [:events, :create_fits_for_tree, :export, :export_tree, :fixity_check]
  layout 'public', only: [:public]

  def show
    @directory = CfsDirectory.includes(:subdirectories, :cfs_files).find(params[:id])
    @accrual = Accrual.new(cfs_directory: @directory)
    @breadcrumbable = @directory
    @file_group = @directory.file_group
    redirect_to @file_group and return if @directory.root? and @file_group.present?
    respond_to do |format|
      format.html
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
    Job::CfsDirectoryExport.create_for(@directory, current_user, false)
  end

  def export_tree
    authorize! :export, @directory.file_group
    Job::CfsDirectoryExport.create_for(@directory, current_user, true)
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
    @events = @eventable.combined_events
  end

  protected

  def find_directory
    @directory = CfsDirectory.find(params[:id])
    @breadcrumbable = @directory
  end

end