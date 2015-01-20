class Event < ActiveRecord::Base
  belongs_to :eventable, polymorphic: true, touch: true

  validates_inclusion_of :key, in: lambda { |event| event.eventable.supported_event_keys }
  validates :actor_email, email: true
  validates_presence_of :date

  before_create :ensure_date

  def message
    self.eventable.event_message(self.key)
  end

  def ensure_date
    self.date ||= Date.today
  end

end
