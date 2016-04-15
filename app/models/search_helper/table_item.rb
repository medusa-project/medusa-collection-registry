class SearchHelper::TableItem < SearchHelper::TableBase

  attr_accessor :project, :batch

  def base_class
    ::Item
  end

  def initialize(args = {})
    super
    self.project = args[:project]
    self.batch = args[:batch]
  end

  def table_id
    'items'
  end

  def url
    Rails.application.routes.url_helpers.items_project_path(project, format: :json, batch: batch)
  end

  def full_count
    project.items.count
  end

  def order_direction
    super || 'desc'
  end

  def order_field
    super || 'updated_at'
  end

  def search
    @search ||= base_class.search do
      fulltext search_string, fields: search_fields
      paginate page: page, per_page: per_page
      order_by order_field, order_direction
      all_of do
        with :project_id, project.id
        with :batch, batch if batch.present?
      end
    end
  end

  def columns
    [{header: 'Action', value_method: :action_buttons, unsortable: true},
     {header: 'Mass Action', value_method: ->(decorated_item) { decorated_item.assign_checkbox(project) }, unsortable: true},
     {header: 'Barcode', solr_field: :barcode, value_method: :search_barcode_link, searchable: true},
     {header: 'Bib Id', solr_field: :bib_id, value_method: :bib_id, searchable: true},
     {header: 'Oclc Number', solr_field: :oclc_number, value_method: :oclc_number, searchable: true},
     {header: 'Call Number', solr_field: :call_number, value_method: :call_number, searchable: true},
     {header: 'Title', solr_field: :some_title, value_method: :some_title, searchable: true},
     {header: 'Author', solr_field: :author, value_method: :author, searchable: true},
     {header: 'Imprint', solr_field: :imprint, value_method: :imprint, searchable: true},
     {header: 'Reformatting Date', solr_field: :reformatting_date, value_method: :reformatting_date, searchable: true},
     {header: 'Reformatting Operator', solr_field: :reformatting_operator, value_method: :reformatting_operator, searchable: true},
     {header: 'Notes', solr_field: :notes, value_method: :notes, searchable: true},
     {header: 'Batch', solr_field: :batch, value_method: :search_batch_link, searchable: true},
     {header: 'Local Title', solr_field: :local_title, value_method: :local_title, searchable: true},
     {header: 'Local Description', solr_field: :local_description, value_method: :local_description, searchable: true},
     {header: 'Record Series Id', solr_field: :record_series_id, value_method: :record_series_id, searchable: true},
     {header: 'Archival Management System Url', solr_field: :archival_management_system_url, value_method: :archival_management_system_url, searchable: true},
     {header: 'Series', solr_field: :series, value_method: :series, searchable: true},
     {header: 'Sub-series', solr_field: :sub_series, value_method: :sub_series, searchable: true},
     {header: 'Box', solr_field: :box, value_method: :box, searchable: true}
    ]
  end

end