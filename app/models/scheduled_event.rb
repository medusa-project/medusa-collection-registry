class ScheduledEvent < ActiveRecord::Base
  belongs_to :scheduled_eventable, polymorphic: true, touch: true

  STATES = ['scheduled', 'completed', 'cancelled']

  validates_inclusion_of :key, in: lambda { |event| event.scheduled_eventable.supported_scheduled_event_keys }
  validates :actor_email, email: true
  validates_presence_of :action_date
  validates_inclusion_of :state, in: STATES
  before_validation :ensure_state

  def self.incomplete
    where("state != 'completed'")
  end

  def message
    self.scheduled_eventable.scheduled_event_message(self.key)
  end

  def ensure_state
    self.state ||= 'scheduled'
  end

  def enqueue_initial
    Delayed::Job.enqueue(self, run_at: self.action_date)
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

  def scheduled?
    self.state == 'scheduled'
  end

  def be_complete(completing_user)
    self.transaction do
      self.state = 'completed'
      self.create_completion_event(completing_user)
      self.save!
    end
  end

  def be_cancelled
    self.state = 'cancelled'
    self.save!
  end

  def create_completion_event(completing_user)
    e = self.scheduled_eventable.events.build(actor_email: completing_user.email, key: self.scheduled_eventable.normal_event_key(self.key), date: Date.today)
    e.save!
  end

  def select_options
    self.scheduled_eventable.scheduled_event_select_options
  end

end
