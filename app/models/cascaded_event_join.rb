class CascadedEventJoin < ActiveRecord::Base
  belongs_to :cascaded_eventable, polymorphic: true
  belongs_to :event
  delegate :created_at, :actor_email, :message, :note, :date, to: :event, prefix: true

  validates_presence_of :event_id, :cascaded_eventable_id, :cascaded_eventable_type

  searchable include: [{event: :eventable}, :cascaded_eventable] do
    time :event_created_at
    text :eventable_label
    string :eventable_label
    text :eventable_type
    string :eventable_type
    text :eventable_parent_label
    string :eventable_parent_label
    text :event_actor_email
    string :event_actor_email
    text :event_message
    string :event_message
    text :event_note
    string :event_note
    integer :cascaded_eventable_id
    string :cascaded_eventable_type
    integer :event_id
  end

  def eventable_label
    event.eventable.decorate.label if event.eventable
  end

  def eventable_type
    event.eventable.decorate.decorated_class_human if event.eventable
  end

  def eventable_parent_label
    event.eventable.parent.decorate.label if event.eventable and event.eventable.parent
  end

end
