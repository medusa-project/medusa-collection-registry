class SearchHelper::TableEvent < SearchHelper::TableBase

  attr_accessor :cascaded_eventable

  def base_class
    ::CascadedEventJoin
  end

  def initialize(args = {})
    super
    self.cascaded_eventable = args[:cascaded_eventable]
  end

  def table_id
    'cascaded_events'
  end

  def url
    cascaded_eventable.decorate.events_path(format: :json)
  end

  def full_count
    cascaded_eventable.cascaded_events.count
  end

  def order_direction
    super || 'desc'
  end

  def order_field
    super || 'event_created_at'
  end

  def search
    @search ||= base_class.search do
      fulltext search_string, fields: search_fields
      paginate page: page, per_page: per_page
      order_by order_field, order_direction
      all_of do
        with :cascaded_eventable_id, cascaded_eventable.id
        with :cascaded_eventable_type, cascaded_eventable_type
      end
    end
  end

  def columns
    [
        {header: 'Time', solr_field: :event_created_at, value_method: :event_date},
        {header: 'Label', solr_field: :eventable_label, value_method: :search_eventable_link, searchable: true},
        {header: 'Type', solr_field: :cascaded_eventable_type, value_method: :cascaded_eventable_type, searchable: true},
        {header: 'Parent', solr_field: :eventable_parent_label, value_method: :search_eventable_parent_link, searchable: true},
        {header: 'User', solr_field: :event_actor_email, value_method: :event_actor_email, searchable: true},
        {header: 'Message', solr_field: :event_message, value_method: :event_message, searchable: true},
        {header: 'Note', solr_field: :event_note, value_method: :event_note, searchable: true},
        {header: 'Actions', value_method: :action_buttons, unsortable: true}
    ]
  end

  def cascaded_eventable_type
    if cascaded_eventable.is_a?(FileGroup)
      'FileGroup'
    else
      cascaded_eventable.class.to_s
    end
  end

end