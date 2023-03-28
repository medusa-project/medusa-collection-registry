class Workflow::AccrualJobsController < ApplicationController

  before_action :require_medusa_user
  before_action :get_accrual_job_and_authorize,
                only: [:proceed, :show, :proceed_form, :abort, :abort_form, :view_report]
  before_action :record_comment, only: [:proceed, :abort]

  def show
  end
  
  def proceed
    @accrual_job.approve_and_proceed
    respond_to do |format|
      format.js
      format.html do
        redirect_back fallback_location: dashboard_path
      end
    end
  end

  def proceed_form

  end

  def abort
    @accrual_job.abort_and_proceed
    respond_to do |format|
      format.js
      format.html do
        redirect_back fallback_location: dashboard_path
      end
    end
  end

  def abort_form

  end

  def view_report
    respond_to do |format|
      @workflow_accrual = @accrual_job
      format.js
    end
  end

  protected

  def check_authorization(job)
    case job.state
      when 'initial_approval'
        authorize! :accrue, job.cfs_directory
      when 'admin_approval'
        authorize! :accrue_admin, job.cfs_directory
      else
        authorize! :manage, job.cfs_directory
    end
  end

  def get_accrual_job_and_authorize
    @accrual_job = Workflow::AccrualJob.find(params[:id])
    check_authorization(@accrual_job)
  end

  def record_comment
    comment = params[:workflow_accrual_job].try(:fetch, :comment)
    if comment.present?
      @accrual_job.workflow_accrual_comments.create!(user: current_user,
                                                     body: comment)
    end
  end

end