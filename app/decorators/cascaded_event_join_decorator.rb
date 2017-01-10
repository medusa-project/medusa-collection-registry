class CascadedEventJoinDecorator < BaseDecorator

  def action_buttons
    h.small_edit_button(event) +
        h.small_delete_button(event, message: h.event_confirm_message)
  end

  def search_eventable_link
    h.link_to(event.eventable.decorate.label, event.eventable)
  end

  def search_eventable_parent_link
    h.link_to(event.eventable.parent.decorate.label, event.eventable.parent)
  end

end