class CascadedEventJoin < ActiveRecord::Base
  belongs_to :cascaded_eventable, polymorphic: true
  belongs_to :event

  validates_presence_of :event_id, :cascaded_eventable_id, :cascaded_eventable_type

end
