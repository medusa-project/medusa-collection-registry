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
     {header: 'Item information', value_method: :item_information, unsortable: true, item_info: true},
     {header: 'Unique Identifier', solr_field: :unique_identifier, value_method: :unique_identifier, searchable: true},
     {header: 'Batch', solr_field: :batch, value_method: :search_batch_link, searchable: true},
     {header: 'Requester Info', solr_field: :requester_info, value_method: :search_requester_info, searchable: true},
     {header: 'E-Book Status', solr_field: :ebook_status, value_method: :search_ebook_status, searchable: true},
     {header: 'External Link', solr_field: :external_link, value_method: :search_external_link, searchable: true},
     {header: 'Reviewed By', solr_field: :reviewed_by, value_method: :search_reviewed_by searchable: true},
     {header: 'Barcode', solr_field: :barcode, value_method: :search_barcode_link, searchable: true},
     {header: 'File Count', solr_field: :file_count, value_method: :file_count, searchable: true},
     {header: 'Notes', solr_field: :notes, value_method: :notes, searchable: true, shorten: true},
     {header: 'Record Series Id', solr_field: :record_series_id, value_method: :record_series_id, searchable: true},
     {header: 'Bib Id', solr_field: :bib_id, value_method: :bib_id, searchable: true},
     {header: 'Rights Information', solr_field: :rights_information, value_method: :rights_information, searchable: true},
     {header: 'Item Number', solr_field: :item_number, value_method: :item_number, searchable: true},
     {header: 'Local Title', solr_field: :local_title, value_method: :local_title, searchable: true},
     {header: 'Status', solr_field: :status, value_method: :status, searchable: true},
     {header: 'Reformatting Date', solr_field: :reformatting_date, value_method: :reformatting_date, searchable: true},
     {header: 'Reformatting Operator', solr_field: :reformatting_operator, value_method: :reformatting_operator, searchable: true},
     {header: 'Equipment', solr_field: :equipment, value_method: :equipment, searchable: true},
     {header: 'Foldout Present', solr_field: :foldout_present, value_method: :foldout_present},
     {header: 'Foldout Done', solr_field: :foldout_done, value_method: :foldout_done},
     {header: 'Item Done', solr_field: :item_done, value_method: :item_done},
     {header: 'Ingested', value_method: :ingested, unsortable: true},
     {header: 'Local Description', solr_field: :local_description, value_method: :local_description, searchable: true, shorten: true},
     #Catalog Fields
     {header: 'Call Number', solr_field: :call_number, value_method: :call_number, searchable: true},
     {header: 'Title', solr_field: :title, value_method: :title, searchable: true, shorten: true},
     {header: 'Author', solr_field: :author, value_method: :author, searchable: true, shorten: true},
     {header: 'Imprint', solr_field: :imprint, value_method: :imprint, searchable: true, shorten: true},
     {header: 'Oclc Number', solr_field: :oclc_number, value_method: :oclc_number, searchable: true},
     #Archival Fields
     {header: 'Archival Management System Url', solr_field: :archival_management_system_url, value_method: :archival_management_system_url, searchable: true},
     {header: 'Series', solr_field: :series, value_method: :series, searchable: true},
     {header: 'Sub-series', solr_field: :sub_series, value_method: :sub_series, searchable: true},
     {header: 'Box', solr_field: :box, value_method: :box, searchable: true},
     {header: 'Folder', solr_field: :folder, value_method: :folder, searchable: true},
     {header: 'Item Title', solr_field: :item_title, value_method: :item_title, searchable: true},
     {header: 'Source Media', solr_field: :source_media, value_method: :source_media, searchable: true},
     {header: 'Creator', solr_field: :creator, value_method: :creator, searchable: true},
     {header: 'Date', solr_field: :date, value_method: :date, searchable: true}
    ]
  end

end