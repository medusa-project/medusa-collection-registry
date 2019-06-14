class Project < ApplicationRecord
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:manager)
  email_person_association(:owner)

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :items, -> {order 'created_at desc'}, dependent: :destroy do
    def find_by_ingest_identifier(ingest_identifier)
      find_by(unique_identifier: ingest_identifier).if_blank(find_by(bib_id: ingest_identifier))
    end
  end
  has_many :workflow_project_item_ingests, :class_name => 'Workflow::ProjectItemIngest', dependent: :destroy
  belongs_to :collection

  STATUSES = %w(active inactive completed)

  validates_presence_of :start_date, :title, :manager_id, :owner_id, :collection_id, :status
  validates_inclusion_of :status, in: STATUSES
  delegate :title, to: :collection, prefix: true
  delegate :repository, :repository_title, to: :collection

  standard_auto_html(:specifications, :summary)

  before_save :normalize_ingest_folder
  before_save :ensure_collection_uuid

  def staging_key_prefix
    ingest_folder
  end

  def staging_root
    Settings.project_staging_directory
  end

  def target_cfs_directory
    target = MedusaUuid.find_by(uuid: destination_folder_uuid).try(:uuidable)
    target = target.cfs_directory if target.is_a?(BitLevelFileGroup)
    raise RuntimeError, "Destination cfs directory not found for project #{id}" unless target.is_a?(CfsDirectory)
    raise RuntimeError, "Destination cfs directory is not in the correct collection for project #{id}" unless target.collection == collection
    return target
  end

  def target_key_prefix
    target_cfs_directory.relative_path
  end

  def normalize_ingest_folder
    unless self.ingest_folder.nil?
      self.ingest_folder = ingest_folder.sub(/^\/*/, '')
      self.ingest_folder = ingest_folder.sub(/\/*$/, '')
    end
  end

  def ensure_collection_uuid
    self.collection_uuid ||= self.collection.uuid
  end

end