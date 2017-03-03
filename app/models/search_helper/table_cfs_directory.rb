class SearchHelper::TableCfsDirectory < SearchHelper::TableBase

  attr_accessor :cfs_directory

  def base_class
    ::CfsDirectory
  end

  def initialize(args = {})
    super
    self.cfs_directory = args[:cfs_directory]
  end

  def table_id
    'directory_subdirectories'
  end

  def url
    Rails.application.routes.url_helpers.cfs_directories_cfs_directory_path(cfs_directory, format: :json)
  end

  def full_count
    cfs_directory.subdirectories.count
  end

  def order_direction
    super || 'asc'
  end

  def order_field
    super || 'path'
  end

  def search
    @search ||= base_class.search do
      fulltext search_string, fields: search_fields
      paginate page: page, per_page: per_page
      order_by  order_field, order_direction
      with :parent_id, cfs_directory.id
      with :parent_type, 'CfsDirectory'
    end
  end

  def columns
    [
        {header: 'Name', solr_field: :path, value_method: :search_cfs_directory_link_with_icon, searchable: true},
    ]
  end

end