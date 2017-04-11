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
      @workflow.approver = current_user
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

  def new
    @file_group = FileGroup.find(params[:file_group_id])
    authorize! :destroy, @file_group
    @workflow = Workflow::FileGroupDelete.new(file_group_id: @file_group.id)
  end

  def create
    workflow_params = params[:workflow_file_group_delete]
    @file_group = FileGroup.find(workflow_params[:file_group_id])
    authorize! :destroy, @file_group
    @workflow = Workflow::FileGroupDelete.new(file_group_id: @file_group.id, requester: current_user,
                                              requester_reason: workflow_params[:requester_reason], state: 'start')
    if @workflow.save
      @workflow.put_in_queue
      flash[:notice] = 'Your request to delete this file group has been created'
      redirect_to @file_group
    else
      render 'new'
    end
  end

  def restore_content
    @workflow = Workflow::FileGroupDelete.find(params[:id])
    authorize! :decide, @workflow
    flash[:notice] = @workflow.restore_content_requested
    redirect_to dashboard_path
  end

end