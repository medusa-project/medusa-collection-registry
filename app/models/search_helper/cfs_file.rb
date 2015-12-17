class SearchHelper::CfsFile < SearchHelper::SearchBase

  def base_class
    ::CfsFile
  end

  def columns
    [{header: 'Filename', solr_field: :name, value_method: :search_cfs_file_link, searchable: true},
     {header: 'Path', solr_field: :path, value_method: :search_cfs_directory_path},
     {header: 'File Group', solr_field: :file_group_title, value_method: :search_file_group_link},
     {header: 'Collection', solr_field: :collection_title, value_method: :search_collection_link}]
  end

  def tab_label
    'Files'
  end

end