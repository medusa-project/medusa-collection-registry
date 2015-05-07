class AccrualsController < ApplicationController

  def update_display
    directory = CfsDirectory.find(params[:cfs_directory_id])
    authorize! :accrue, directory
    @accrual = Accrual.new(cfs_directory: directory, staging_path: params[:staging_path]).decorate
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      #TODO redirect appropriately and modify redirect targets to do the right thing when that happens
    end
  end

  def submit
    cfs_directory = CfsDirectory.find params[:accrual][:cfs_directory_id]
    authorize! :accrue, cfs_directory
    staging_path = params[:accrual][:staging_path]
    accrual_directories = params[:accrual][:accrual_directories].select {|d| d.present?}
    accrual_files = params[:accrual][:accrual_files].select {|f| f.present?}
    #make and start accrual job with above information
    flash[:notice] = "Accrual to #{cfs_directory.relative_path} accepted. #{accrual_directories.count} #{'directory'.pluralize(accrual_directories.count)} and #{accrual_files.count} #{'file'.pluralize(accrual_files.count)} to be ingested."
    redirect_to cfs_directory
  end

end