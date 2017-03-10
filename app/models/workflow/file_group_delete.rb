class Workflow::FileGroupDelete < Workflow::Base

  belongs_to :file_group
  belongs_to :requester, class_name: 'User'
  belongs_to :approver, class_name: 'User'

  before_create :cache_file_group_title

  STATES = %w(start email_superusers wait_decision email_requester_accept email_requester_reject move_content email_requester_final_removal end)
  validates_inclusion_of :state, in: STATES, allow_blank: false

  def perform_start
    be_in_state_and_requeue('email_superusers')
  end

  def perform_email_superusers
    Workflow::FileGroupDeleteMailer.email_superusers(self).deliver_now
    be_in_state('wait_decision')
  end

  def perform_wait_decision
    unrunnable_state
  end

  def perform_email_requester_accept
    Workflow::FileGroupDeleteMailer.requester_accept(self).deliver_now
    be_in_state_and_requeue('move_content')
  end

  def perform_email_requester_reject
    Workflow::FileGroupDeleteMailer.requester_reject(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_email_requester_final_removal
    Workflow::FileGroupDeleteMailer.requester_final_removal(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_end
    destroy_queued_jobs_and_self
  end

  def approver_email
    approver.present? ? approver.email : 'Unknown'
  end

  def cache_file_group_title
    self.cached_file_group_title ||= file_group.title
  end

end
