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
    CascadedEventJoin.find_or_create_by(cascaded_eventable: self.eventable, event_id: self.id)
    if self.cascadable and self.eventable.respond_to?(:cascade_event)
      self.eventable.cascade_event(self)
    end
  end

  #TODO - can we do this in SQL to make it run in a reasonable amount of time? Or at least speed it up somehow?
  #Maybe we could do all the initial level ones via sql, then reindex them in solr, then create the cascading ones as we do now
  def self.rebuild_cascaded_event_cache
    CascadedEventJoin.delete_all
    sql = <<SQL
    INSERT INTO cascaded_event_joins (cascaded_eventable_id, cascaded_eventable_type, event_id, created_at, updated_at)
    SELECT eventable_id, eventable_type, id, now(), now() FROM events
SQL
    CascadedEventJoin.connection.execute(sql)
    CascadedEventJoin.reindex
    self.includes(:eventable).where(cascadable: true).find_each(batch_size: 100) do |event|
      transaction do
        event.maybe_cascade
      end
    end
  end

end
