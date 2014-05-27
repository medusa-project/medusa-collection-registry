class CfsDirectoriesController < ApplicationController

  before_filter :require_logged_in, except: [:show]
  before_filter :require_logged_in_or_basic_auth, only: [:show]

  def show
    @directory = CfsDirectory.includes(:subdirectories, :cfs_files).find(params[:id])
    @file_group = @directory.owning_file_group
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create_fits_for_tree
    @directory = CfsDirectory.find(params[:id])
    authorize! :create_cfs_fits, @directory.owning_file_group
    Job::FitsDirectoryTree.create_for(@directory)
    flash[:notice] = "Scheduling FITS creation for /#{@directory.relative_path}"
    redirect_to @directory
  end
  #Delayed::Job.enqueue(Job::FitsDirectoryTree.create(:path => params[:path]), :priority => 50)

  def export
    @directory = CfsDirectory.find(params[:id])
    authorize! :export, @directory.owning_file_group
    Job::CfsDirectoryExport.create_for(@directory, current_user, false)
  end

  def export_tree
    @directory = CfsDirectory.find(params[:id])
    authorize! :export, @directory.owning_file_group
    Job::CfsDirectoryExport.create_for(@directory, current_user, true)
  end

end