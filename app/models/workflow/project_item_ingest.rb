class Workflow::ProjectItemIngest < Workflow::Base
  STATES = %w(start email_started ingest email_done end)

  validates_inclusion_of :state, in: STATES, allow_blank: false

  def perform_end
    self.destroy!
  end

  def perform_email_started
    #email user that the ingest has started along with some details about it
    be_in_state_and_requeue('ingest')
  end

end
