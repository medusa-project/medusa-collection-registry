class IngestStatus < ActiveRecord::Base
  attr_accessible :collection_id, :date, :notes, :staff, :state

  INGEST_STATUS_STATES = [:unstarted, :started, :complete]

  validates_presence_of :collection_id
  validates_inclusion_of :state, :in => INGEST_STATUS_STATES

  before_validation :symbolize_state

  def symbolize_state
    self.state = self.state.to_sym
  end

end
