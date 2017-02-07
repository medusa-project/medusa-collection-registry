class Item < ActiveRecord::Base
  belongs_to :project, touch: true
  has_one :workflow_item_ingest_request, :class_name => 'Workflow::ItemIngestRequest', dependent: :destroy
  delegate :title, to: :project, prefix: true
  delegate :source_media_types, to: :class

  before_validation :ensure_barcode
  auto_strip_attributes :barcode, nullify: false

  expose_class_config :source_media_types, :equipment_types, :statuses
  validates :status, inclusion: {in: :statuses}, allow_blank: true
  validates :source_media, inclusion: {in: :source_media_types}, allow_blank: true
  validates :barcode, allow_blank: true, format: /\d{14}/

  searchable include: :project do
    %i(barcode batch).each do |field|
      text field
      string field, stored: true
    end
    %i(some_title bib_id call_number author record_series_id oclc_number imprint local_title local_description
reformatting_operator archival_management_system_url series sub_series box folder item_title creator date
rights_information status equipment unique_identifier item_number source_media).each do |field|
      text field
      string field
    end
    %i(foldout_present foldout_done item_done).each do |field|
      boolean field
    end
    text :notes
    string :project_title
    integer :project_id
    integer :file_count
    time :updated_at
    date :reformatting_date
  end

  def ensure_barcode
    self.barcode ||= ''
  end

  def some_title
    title.if_blank(item_title.if_blank(local_title))
  end

  def staging_directory
    File.join(project.staging_directory, ingest_identifier)
  end

  def ingest_identifier
    unique_identifier
  end

end
