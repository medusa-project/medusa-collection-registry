class Workflow::FileGroupDeletesController < ApplicationController

  before_action :require_medusa_user

  def admin_decide
    @workflow = Workflow::FileGroupDelete.find(params[:id])
    authorize! :decide, @workflow
  end

  def admin_record_decision
    @workflow = Workflow::FileGroupDelete.find(params[:id])
    authorize! :decide, @workflow
    if @workflow.state == 'wait_decision'
      @workflow.approver_reason = params[:workflow_file_group_delete][:approver_reason]
      @workflow.state = case params[:commit]
                          when 'Approve'
                            'email_requester_accept'
                          when 'Reject'
                            'email_requester_reject'
                          else
                            raise RuntimeError, 'Unrecognized submit button'
                        end
      @workflow.save!
      @workflow.put_in_queue
    end
    redirect_to dashboard_path
  end

end