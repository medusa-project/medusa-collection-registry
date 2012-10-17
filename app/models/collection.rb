require 'net_id_person_associator'
require 'utils/luhn'

class Collection < ActiveRecord::Base
  net_id_person_association(:contact)
  attr_accessible :access_url, :description, :private_description, :end_date, :file_package_summary, :notes,
                  :ongoing, :published, :repository_id, :rights_restrictions, :rights_statement,
                  :start_date, :title, :access_system_ids, :preservation_priority_id, :resource_type_ids

  belongs_to :repository
  has_many :assessments, :dependent => :destroy
  has_many :file_groups, :dependent => :destroy
  has_many :access_system_collection_joins, :dependent => :destroy
  has_many :access_systems, :through => :access_system_collection_joins
  has_many :collection_resource_type_joins, :dependent => :destroy
  has_many :resource_types, :through => :collection_resource_type_joins
  has_one :ingest_status, :dependent => :destroy
  belongs_to :preservation_priority

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :repository_id
  validates_presence_of :repository_id
  validates_presence_of :preservation_priority_id
  validates_uniqueness_of :uuid
  validates_each :uuid do |record, attr, value|
    record.errors.add attr, 'is not a valid uuid' unless Utils::Luhn.verify(value)
  end

  after_create :ensure_ingest_status
  after_create :ensure_handle
  before_validation :ensure_uuid

  [:description, :private_description, :notes, :file_package_summary].each do |field|
    auto_html_for field do
      html_escape
      link :target => "_blank"
      simple_format
    end
  end

  def total_size
    self.file_groups.sum(:total_file_size)
  end

  def ensure_ingest_status
    self.ingest_status ||= IngestStatus.new(:state => :unstarted)
  end

  def ensure_uuid
    self.uuid ||= Utils::Luhn.add_check_character(UUID.generate)
  end

  def ensure_handle
    client = MedusaRails3::Application.handle_client
    if self.handle and client
      if client.exists?(self.handle)
        client.update_url(self.handle, self.medusa_url)
      else
        client.create_from_url(self.handle, self.medusa_url)
      end
    end
  end

  def remove_handle
    client = MedusaRails3::Application.handle_client
    if self.handle and client
      if client.exists?(self.handle)
        client.delete(self.handle)
      end
    end
  end

  def handle
    self.uuid ? "10111/MEDUSA:#{self.uuid}" : nil
  end

  def medusa_url
    Rails.application.routes.url_helpers.medusa_url(self, :host => MedusaRails3::Application.medusa_host, :protocol => 'https')
  end

  def resource_type_names
    self.resource_types.collect(&:name).join('; ')
  end

  def preservation_priority_name
    self.preservation_priority.try(:name)
  end

end
