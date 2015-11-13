class SearchHelper::Item < SearchHelper::Base

  def base_class
    ::Item
  end

  def columns
    [{header: 'Barcode', solr_field: :barcode, value_method: :search_barcode_link, searchable: true},
     {header: 'Title', solr_field: :title, value_method: :title},
     {header: 'Project', solr_field: :project_title, value_method: :search_project_link}]
  end

end