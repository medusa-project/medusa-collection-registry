class SearchHelper::TableCfsFile < SearchHelper::TableBase

  attr_accessor :cfs_directory

  def base_class
    ::CfsFile
  end

  def initialize(args = {})
    super
    self.cfs_directory = args[:cfs_directory]
  end

  def table_id
    'directory_files'
  end

  def url
    Rails.application.routes.url_helpers.cfs_files_cfs_directory_path(cfs_directory, format: :json)
  end

  def full_count
    cfs_directory.cfs_files.count
  end

  def order_direction
    super || 'asc'
  end

  def order_field
    super || 'name'
  end

  def search
    @search ||= base_class.search do
      fulltext search_string, fields: search_fields
      paginate page: page, per_page: per_page
      order_by  order_field, order_direction
      with :cfs_directory_id, cfs_directory.id
    end
  end

  def columns
    [
        {header: 'Thumbnail', value_method: :search_thumbnail_link, unsortable: true},
        {header: 'Name', solr_field: :name, value_method: :search_cfs_file_link, searchable: true},
        {header: 'Size', solr_field: :size, value_method: :size},
        {header: 'Last Modified', solr_field: :mtime, value_method: :mtime},
        {header: 'FITS', value_method: :fits_button, unsortable: true}
    ]
  end

end