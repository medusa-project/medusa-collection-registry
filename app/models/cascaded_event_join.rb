class CascadedEventJoin < ActiveRecord::Base
  belongs_to :cascaded_eventable, polymorphic: true
  belongs_to :event

  validates :event_id, presence: true
  validates :cascaded_eventable_id, presence: true
  validates :cascaded_eventable, presence: true

end
