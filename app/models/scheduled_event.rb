class ScheduledEvent < ActiveRecord::Base
  attr_accessible :action_date, :actor_netid, :key, :note, :scheduled_eventable_id, :scheduled_eventable_type, :state

  belongs_to :scheduled_eventable, :polymorphic => true

  STATES = ['scheduled', 'completed', 'cancelled']

  validates_inclusion_of :key, :in => lambda { |event| event.scheduled_eventable.supported_scheduled_event_keys }
  validates_format_of :actor_netid, :with => /^[A-Za-z0-9]+$/
  validates_presence_of :action_date
  validates_inclusion_of :state, :in => STATES
  before_validation :ensure_state

  def message
    self.scheduled_eventable.scheduled_event_message(self.key)
  end

  def ensure_state
    self.state ||= 'scheduled'
  end

  def enqueue
    Delayed::Job.enqueue(self, :run_at => self.action_date)
  end

  def perform
    self.send("perform_#{self.state}")
  end

  def perform_scheduled
    #mail reminder
    ScheduledEventMailer.reminder(self).deliver
    #reschedule self - avoid endless loop in test system
    unless Rails.env.test?
      Delayed::Job.enqueue(self, :run_at => Date.today + 7.days)
    end
  end

  def perform_completed
    self.destroy
  end

  def perform_cancelled
    self.destroy
  end

end
