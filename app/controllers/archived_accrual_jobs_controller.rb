class ArchivedAccrualJobsController < ApplicationController

  before_filter :require_logged_in

  def show
    @archived_accrual_job = ArchivedAccrualJob.find(params[:id])
    authorize! :read, @archived_accrual_job
  end

  def index
    authorize! :read, ArchivedAccrualJob
  end

end