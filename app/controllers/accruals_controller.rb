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
    clean_staging_path = Nokogiri::HTML.parse(staging_path).text
    accrual_directories = params[:accrual][:accrual_directories].select {|d| d.present?}
    accrual_files = params[:accrual][:accrual_files].select {|f| f.present?}
    allow_overwrite = params[:accrual][:allow_overwrite]
    Workflow::AccrualJob.create_for(current_user, cfs_directory, clean_staging_path, accrual_files, accrual_directories, allow_overwrite)
    flash[:notice] = submission_notice
    redirect_to cfs_directory
  end

  protected

  def submission_notice
    %Q(Your ingest request has been submitted to a your Repository Administrator and
       is pending approval. Prior to approval, a pre-ingest report will be made available
       in the #{view_context.link_to('Medusa Dashboard', dashboard_path)} with a technical analysis of your
       deposit.).html_safe
  end

end