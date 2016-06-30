class SearchHelper::MedusaUuid < SearchHelper::SearchBase

  def base_class
    ::MedusaUuid
  end

  def columns
    [
     {header: 'UUID', solr_field: :uuid, value_method: :search_uuid_link, searchable: true},
     {header: 'Label', value_method: :search_uuid_label},
     {header: 'Type', value_method: :uuidable_type}
    ]
  end

  def tab_label
    'UUIDs'
  end

  def table_id
    'search_uuids'
  end

end