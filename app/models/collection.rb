require 'net_id_person_associator'
class Collection < ActiveRecord::Base
  net_id_person_association(:contact)
  attr_accessible :access_url, :description, :private_description, :end_date, :file_package_summary, :notes,
                  :ongoing, :published, :repository_id, :rights_restrictions, :rights_statement,
                  :start_date, :title, :content_type_id, :access_system_ids, :object_type_ids,
                  :preservation_priority_id, :resource_type_ids

  belongs_to :repository
  belongs_to :content_type
  has_many :assessments, :dependent => :destroy
  has_many :file_groups, :dependent => :destroy
  has_many :access_system_collection_joins, :dependent => :destroy
  has_many :access_systems, :through => :access_system_collection_joins
  has_many :collection_object_type_joins, :dependent => :destroy
  has_many :object_types, :through => :collection_object_type_joins
  has_many :collection_resource_type_joins, :dependent => :destroy
  has_many :resource_types, :through => :collection_resource_type_joins
  has_one :ingest_status, :dependent => :destroy
  belongs_to :preservation_priority

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :repository_id
  validates_presence_of :repository_id
  validates_presence_of :preservation_priority_id

  after_create :ensure_ingest_status

  [:description, :private_description, :notes].each do |field|
    auto_html_for field do
      html_escape
      link :target => "_blank"
    end
  end


  def total_size
    self.file_groups.sum(:total_file_size)
  end

  def ensure_ingest_status
    self.ingest_status ||= IngestStatus.new(:state => :unstarted)
  end

  def content_type_name
    self.content_type.try(:name)
  end

  def object_type_names
    self.object_types.collect(&:name).join(', ')
  end

  def resource_type_names
    self.resource_types.collect(&:name).join('; ')
  end

  def preservation_priority_name
    self.preservation_priority.try(:name)
  end

end
