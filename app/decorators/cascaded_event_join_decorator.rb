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

  #If the note requires special handling based on the key then we can provide it; otherwise just use it as is
  #For example, for a project item ingest event we know the note has the item database ids, so we can link them
  #with a little extra processing.
  def render_event_note
    case event.key
      when 'project_item_ingest'
        render_project_item_ingest_note(event.note)
      else
        event.note
    end
  end

  def render_project_item_ingest_note(note)
    note.match(/^(\D+)(.*)$/)
    prefix = $1
    item_list = $2
    item_ids = item_list.split(',')
    items = Item.where(id: item_ids).includes(:cfs_directory)
    item_links = items.collect { |item| item_link(item) }.join(',')
    "#{prefix}#{item_links}"
  rescue
    note
  end

  protected

  def item_link(item)
    path = if item.cfs_directory
             h.cfs_directory_path(item.cfs_directory)
           else
             h.item_path(item)
           end
    h.link_to(item.id, path)
  rescue Exception
    item.id.to_s
  end

end