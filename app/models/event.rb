class Event < ActiveRecord::Base
  attr_accessible :eventable, :key, :note, :actor_netid, :date
  belongs_to :eventable, :polymorphic => true

  validates_inclusion_of :key, :in => lambda {|event| event.eventable.supported_event_keys}
  validates_format_of :actor_netid, :with => /^[A-Za-z0-9]+$/
  validates_presence_of :date

  def message
    self.eventable.event_message(self.key)
  end

end
