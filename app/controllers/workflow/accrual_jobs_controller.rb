class Workflow::AccrualJobsController < ApplicationController

  before_action :require_logged_in

  def proceed
    @accrual_job = Workflow::AccrualJob.find(params[:id])
    check_authorization(@accrual_job)
    @accrual_job.approve_and_proceed
    respond_to do |format|
      format.js
      format.html do
        redirect_to :back
      end
    end
  end

  protected

  def check_authorization(job)
    case job.state
      when 'initial_approval'
        authorize! :accrue, job.cfs_directory
      when 'overwrite_approval'
        authorize! :accrue_overwrite, job.cfs_directory
      else
        authorize! :manage, job.cfs_directory
    end
  end

end