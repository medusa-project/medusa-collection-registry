class SearchHelper::CfsDirectory < SearchHelper::Base

  def base_class
    ::CfsDirectory
  end

  def columns
    [{header: 'Name', solr_field: :path, value_method: :search_cfs_directory_link, searchable: true},
     {header: 'File Group', solr_field: :file_group_title, value_method: :search_file_group_link},
     {header: 'Collection', solr_field: :collection_title, value_method: :search_collection_link}]
  end

  def tab_label
    'Folders'
  end

end