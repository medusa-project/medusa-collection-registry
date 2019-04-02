  class Item < ApplicationRecord
  belongs_to :project, touch: true
  has_one :workflow_item_ingest_request, :class_name => 'Workflow::ItemIngestRequest', dependent: :destroy
  belongs_to :cfs_directory
  delegate :title, to: :project, prefix: true
  delegate :source_media_types, to: :class

  before_validation :ensure_barcode
  auto_strip_attributes :barcode, nullify: false

  expose_class_config :source_media_types, :equipment_types, :statuses
  validates :status, inclusion: {in: :statuses}, allow_blank: true
  validates :source_media, inclusion: {in: :source_media_types}, allow_blank: true
  validates :barcode, allow_blank: true, format: /\d{14}/

  searchable include: :project do
    integer :model_id, using: :id
    %i(barcode batch).each do |field|
      text field
      string field, stored: true
    end
    %i(some_title bib_id call_number title author record_series_id oclc_number imprint local_title local_description
reformatting_operator archival_management_system_url series sub_series box folder item_title creator date
rights_information status equipment unique_identifier item_number source_media).each do |field|
      text field
      string field
    end
    %i(foldout_present foldout_done item_done).each do |field|
      boolean field
    end
    text :notes
    text :reformatting_date
    date :reformatting_date
    text :file_count
    integer :file_count

    string :project_title
    integer :project_id
    time :updated_at
  end

  def self.uningested
    where(ingested: false)
  end

  def self.ingested
    where(ingested: true)
  end

  #TODO - redefined this because of a problem we saw with Rsolr doing bulk indexes on these.
  # I'm not sure what the problem is, but maybe try to find it, or maybe just rely
  # on a move to elastic search.
  def self.solr_reindex(options = {})
    solr_remove_all_from_index
    Item.all.find_each do |item|
      item.index
    end
    Sunspot.commit(true)
    Sunspot.commit(false)
  end

  def ensure_barcode
    self.barcode ||= ''
  end

  def some_title
    title.if_blank(item_title.if_blank(local_title))
  end

  def staging_key_prefix
    File.join(project.staging_key_prefix, ingest_identifier)
  end

  def ingest_identifier
    unique_identifier.if_blank(bib_id)
  end

  def self.find_by_ingest_identifier(ingest_identifier)
    find_by(unique_identifier: ingest_identifier) || find_by(bib_id: ingest_identifier)
  end

end
