class CascadedEventJoin < ApplicationRecord
  belongs_to :cascaded_eventable, polymorphic: true
  belongs_to :event
  delegate :created_at, :actor_email, :message, :note, :date, to: :event, prefix: true

  validates_presence_of :event_id, :cascaded_eventable_id, :cascaded_eventable_type

  searchable include: [{event: :eventable}, :cascaded_eventable] do
    #base fields to identify and restrict searches
    integer :model_id, using: :id
    text :cascaded_eventable_type
    string :cascaded_eventable_type
    integer :cascaded_eventable_id
    integer :event_id

    #eventable fields
    text :eventable_label
    string :eventable_label
    text :eventable_parent_label
    string :eventable_parent_label

    #event fields
    time :event_created_at
    text :event_actor_email
    string :event_actor_email
    text :event_message
    string :event_message
    text :event_note
    string :event_note
  end

  def eventable_label
    cascaded_eventable.decorate.label
  rescue Exception => e
    GenericErrorMailer.error("No eventable label\n\nCascadedEventJoin: #{self.id}\n\n#{e}\n", subject: 'Cascaded Event error').deliver_now
    return nil
  end

  def eventable_type
    cascaded_eventable.decorate.decorated_class_human
  rescue Exception => e
    GenericErrorMailer.error("No eventable type\n\nCascadedEventJoin: #{self.id}\n\n#{e}\n", subject: 'Cascaded Event error').deliver_now
    return nil
  end

  def eventable_parent_label
    cascaded_eventable.parent.decorate.label if cascaded_eventable.parent.present?
  rescue Exception => e
    GenericErrorMailer.error("No eventable parent label\n\nCascadedEventJoin: #{self.id}\n\n#{e}\n", subject: 'Cascaded Event error').deliver_now
    return nil
  end

end
