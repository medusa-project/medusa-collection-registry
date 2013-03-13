class Event < ActiveRecord::Base
  attr_accessible :eventable, :key, :note, :user_id
  belongs_to :eventable, :polymorphic => true
  belongs_to :user

  validates_inclusion_of :key, :in => lambda {|event| event.eventable.supported_event_keys}
  validates_presence_of :user_id
  validates_associated :user

  def message
    self.eventable.event_message(self.key)
  end
end
