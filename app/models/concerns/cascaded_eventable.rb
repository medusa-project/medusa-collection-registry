#in conjunction with CascadedEventJoin this allows a simple way for Events from child objects to be associated to
#their ancestors, as defined by the parent option of cascades_events. When an event that is cascadable is created for
#an object then if that object includes CascadedEventable then a CascadedEventJoin is created between the event and that
#object. As long as ancestors are found such entries are created for each ancestor as well. Then an ancestor can find
#all of these events by using the cascaded_events association.
require 'active_support/concern'

module CascadedEventable
  extend ActiveSupport::Concern

  included do
    has_many :cascaded_event_joins, as: :cascaded_eventable, dependent: :destroy
    has_many :cascaded_events, -> { order 'date DESC' }, through: :cascaded_event_joins, class_name: 'Event', source: :event
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

  #this method is to give uncascaded events belonging directly to the object together with cascaded events
  def combined_events
    uncascaded_events = if self.respond_to?(:events)
                          self.events.where(cascadable: false)
                        else
                          Array.new
                        end
    return (self.cascaded_events + uncascaded_events).sort { |a, b| b.created_at <=> a.created_at }
  end

end