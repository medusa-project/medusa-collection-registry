class Project < ApplicationRecord
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:manager)
  email_person_association(:owner)

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :items, -> { order 'created_at desc' }, dependent: :destroy do
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

  def staging_directory
    raise RuntimeError, "No ingest folder specified" unless ingest_folder.present?
    File.join(staging_root, ingest_folder)
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

  def target_cfs_directory_path
    target_cfs_directory.absolute_path
  end

end