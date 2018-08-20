class SearchHelper::FileGroup < SearchHelper::SearchBase

  def base_class
    ::FileGroup
  end

  def columns
    [{header: 'Title', solr_field: :title, value_method: :search_file_group_link, searchable: true},
     {header: 'Description', solr_field: :description, value_method: :description, searchable: true}]
  end

end