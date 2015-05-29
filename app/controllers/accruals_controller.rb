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
    Workflow::AccrualJob.create_for(current_user, cfs_directory, staging_path, accrual_files, accrual_directories)
    flash[:notice] = "Your ingest request has been submitted to a Medusa Administrator and is pending approval."
    redirect_to cfs_directory
  end

end