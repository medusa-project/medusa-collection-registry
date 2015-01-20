class Event < ActiveRecord::Base
  belongs_to :eventable, polymorphic: true, touch: true
  has_many :cascaded_event_joins, dependent: :destroy

  validates_inclusion_of :key, in: lambda { |event| event.eventable.supported_event_keys }
  validates :actor_email, email: true
  validates_presence_of :date

  before_validation :ensure_date
  after_create :maybe_cascade

  def message
    self.eventable.event_message(self.key)
  end

  def ensure_date
    self.date ||= Date.today
  end

  def maybe_cascade
    if self.cascadable and self.eventable.respond_to?(:cascade_event)
      self.eventable.cascade_event(self)
    end
  end

  def self.rebuild_cascaded_event_cache
    CascadedEventJoin.find_each {|cascaded_event_join| cascaded_event_join.destroy}
    self.find_each do |event|
      event.maybe_cascade
    end
  end

end
