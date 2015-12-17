class SearchHelper::Collection < SearchHelper::SearchBase

  def base_class
    ::Collection
  end

  def columns
    [{header: 'Title', solr_field: :title, value_method: :search_collection_link, searchable: true},
     {header: 'Description', solr_field: :description, value_method: :description, searchable: true},
     {header: 'External ID', solr_field: :external_id, value_method: :external_id, searchable: true}]
  end

end