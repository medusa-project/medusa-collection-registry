class CfsDirectoriesController < ApplicationController

  before_filter :require_logged_in

  def show
    @directory = CfsDirectory.includes(:subdirectories, :cfs_files).find(params[:id])
    @file_group = @directory.owning_file_group
  end

  def create_fits_for_tree
    @directory = CfsDirectory.find(params[:id])
    authorize! :create_cfs_fits, @directory.owning_file_group
    Job::FitsDirectoryTree.create_for(@directory)
    flash[:notice] = "Scheduling FITS creation for /#{@directory.relative_path}"
    redirect_to @directory
  end
  #Delayed::Job.enqueue(Job::FitsDirectoryTree.create(:path => params[:path]), :priority => 50)

end