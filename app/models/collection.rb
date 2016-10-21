require 'registers_handle'
require 'mods_helper'

class Collection < ActiveRecord::Base
  include MedusaAutoHtml
  include RegistersHandle
  include Uuidable
  include Breadcrumb
  include CascadedEventable
  include CascadedRedFlaggable
  include ResourceTypeable
  include EmailPersonAssociator

  email_person_association(:contact)

  belongs_to :repository
  belongs_to :preservation_priority

  has_many :assessments, dependent: :destroy, as: :assessable
  has_many :file_groups, dependent: :destroy
  has_many :bit_level_file_groups, -> { where('type = ?', 'BitLevelFileGroup') }, class_name: 'FileGroup'
  has_many :access_system_collection_joins, dependent: :destroy
  has_many :access_systems, through: :access_system_collection_joins
  has_one :rights_declaration, dependent: :destroy, autosave: true, as: :rights_declarable
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :projects
  has_many :collection_virtual_repository_joins, dependent: :destroy

  has_many :child_collection_joins, class_name: 'SubcollectionJoin', foreign_key: :parent_collection_id, dependent: :destroy
  has_many :child_collections, -> { order('title ASC') }, through: :child_collection_joins
  has_many :parent_collection_joins, class_name: 'SubcollectionJoin', foreign_key: :child_collection_id, dependent: :destroy
  has_many :parent_collections, -> { order('title ASC') }, through: :parent_collection_joins

  delegate :title, to: :repository, prefix: true
  delegate :name, to: :preservation_priority, prefix: true, allow_nil: true

  validates_presence_of :title
  validates_uniqueness_of :title, scope: :repository_id
  validates_presence_of :repository_id
  validates_presence_of :preservation_priority_id

  after_create :delayed_ensure_handle
  before_destroy :remove_handle
  before_validation :ensure_rights_declaration

  accepts_nested_attributes_for :rights_declaration

  auto_strip_attributes :description, :private_description, :notes, nullify: false

  standard_auto_html(:description, :private_description, :notes)

  breadcrumbs parent: :repository, label: :title
  cascades_events parent: :repository
  cascades_red_flags parent: :repository

  searchable do
    text :title
    string :title
    text :description
    string :description
    text :external_id
    string :external_id
  end

  def total_size
    self.bit_level_file_groups.collect { |fg| fg.file_size }.sum
  end

  def total_files
    self.bit_level_file_groups.collect { |fg| fg.total_files }.sum
  end

  def medusa_url
    Rails.application.routes.url_helpers.collection_url(self, host: MedusaCollectionRegistry::Application.medusa_host, protocol: 'https')
  end

  def ensure_rights_declaration
    self.rights_declaration ||= RightsDeclaration.new(rights_declarable_id: self.id,
                                                      rights_declarable_type: 'Collection')
  end

  def recursive_assessments
    (self.assessments + self.file_groups.collect { |file_group| file_group.assessments }.flatten)
  end

  def to_mods
    metadata_helper.to_mods
  end

  def metadata_helper
    MetadataHelper::Collection.new(self)
  end

  def peer_collections
    repository.collections.order('title ASC').where.not(id: id)
  end

end

