class ArchivedAccrualJobsController < ApplicationController

  before_filter :require_medusa_user

  def show
    @archived_accrual_job = ArchivedAccrualJob.find(params[:id])
    authorize! :read, @archived_accrual_job
  end

  def index
    authorize! :read, ArchivedAccrualJob
  end

end