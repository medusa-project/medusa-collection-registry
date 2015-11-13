class SearchHelper::CfsFile < SearchHelper::Base

  def initialize(args = {})
    super
  end

  def base_class
    ::CfsFile
  end

  def columns
    [{header: 'Filename', solr_field: :name},
     {header: 'Path', solr_field: :path},
     {header: 'File Group', solr_field: :file_group_title},
     {header: 'Collection', solr_field: :collection_title}]
  end

  def search_fields
    [:name]
  end

  def row(cfs_file)
    [:search_cfs_file_link, :search_cfs_directory_path, :search_file_group_link, :search_collection_link].collect {|method| cfs_file.send(method)}
  end

end