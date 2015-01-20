require 'active_support/concern'

module CascadedEventable
  extend ActiveSupport::Concern

  included do
    has_many :cascaded_event_joins, as: :cascaded_eventable, dependent: :destroy
    has_many :cascaded_events, -> {order "date DESC"},  through: :cascaded_event_joins, class_name: 'Event', source: :event
    class_attribute :cascade_events_parent_method
  end

  module ClassMethods
    def cascades_events(options = {})
      self.cascade_events_parent_method = options[:parent] || nil
    end

  end

  def cascade_event(event)
    CascadedEventJoin.find_or_create_by(cascaded_eventable: self, event_id: event.id)
    if self.cascaded_event_parent
      self.cascaded_event_parent.cascade_event(event)
    end
  end

  def cascaded_event_parent
    if parent_method = self.class.cascade_events_parent_method
      self.send(parent_method)
    else
      nil
    end
  end

end