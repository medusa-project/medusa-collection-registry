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

  #Note that we always have a cascaded event join for the model that the event actually
  #belongs to, even if it's not cascadable. I know this is bad terminology, but it seems
  #better to do this way so that we can get all events for an object directly from
  #the cascaded events join table.
  def maybe_cascade
    CascadedEventJoin.find_or_create_by(cascaded_eventable: self, event_id: self.id)
    if self.cascadable and self.eventable.respond_to?(:cascade_event)
      self.eventable.cascade_event(self)
    end
  end

  def self.rebuild_cascaded_event_cache
    CascadedEventJoin.delete_all
    self.find_each do |event|
      event.maybe_cascade
    end
  end

end
