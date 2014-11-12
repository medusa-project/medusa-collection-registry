class FileGroup < ActiveRecord::Base
  include Eventable
  include ScheduledEventable

  belongs_to :collection
  #parent is a duplicate, but allows uniformity for events, i.e. we can do eventable.parent
  belongs_to :parent, class_name: 'Collection', foreign_key: 'collection_id'
  belongs_to :producer
  belongs_to :file_type
  #Note this this only really applies to bit level file groups, but is advantageous to declare here
  belongs_to :cfs_directory

  has_one :rights_declaration, :dependent => :destroy, :autosave => true, :as => :rights_declarable
  has_many :assessments, :as => :assessable, :dependent => :destroy
  has_many :target_file_group_joins, :dependent => :destroy, :class_name => 'RelatedFileGroupJoin', :foreign_key => :source_file_group_id
  has_many :target_file_groups, :through => :target_file_group_joins
  has_many :source_file_group_joins, :dependent => :destroy, :class_name => 'RelatedFileGroupJoin', :foreign_key => :target_file_group_id
  has_many :source_file_groups, :through => :source_file_group_joins
  has_many :events, -> { order 'date DESC' }, :as => :eventable, :dependent => :destroy
  has_many :scheduled_events, -> { order 'action_date ASC' }, :as => :scheduled_eventable, :dependent => :destroy
  belongs_to :package_profile
  has_many :attachments, :as => :attachable, :dependent => :destroy

  before_validation :ensure_rights_declaration
  before_save :canonicalize_cfs_root
  before_save :strip_fields
  before_validation :initialize_file_info

  validates_uniqueness_of :cfs_root, :allow_blank => true
  validates_presence_of :name, :total_files, :total_file_size
  validates_presence_of :producer_id

  STORAGE_LEVEL_HASH = {'external' => 'ExternalFileGroup',
                        'bit-level store' => 'BitLevelFileGroup',
                        'object-level store' => 'ObjectLevelFileGroup'}

  def self.class_for_storage_level(storage_level)
    Kernel.const_get(STORAGE_LEVEL_HASH[storage_level])
  end

  def self.storage_levels
    STORAGE_LEVEL_HASH.keys
  end

  def file_type_name
    self.file_type.try(:name)
  end

  def label
    self.name
  end

  #subclasses should override appropriately - this is blank here to facilitate the form
  def storage_level
    ''
  end

  def json_storage_level
    self.class.to_s.underscore.sub('_file_group', '')
  end

  def ensure_rights_declaration
    self.rights_declaration ||= self.clone_collection_rights_declaration
  end

  def clone_collection_rights_declaration
    RightsDeclaration.new(self.collection.rights_declaration.attributes.slice(
                              :rights_basis, :copyright_jurisdiction,
                              :copyright_statement, :access_restrictions).merge(
                              :rights_declarable_id => self.id,
                              :rights_declarable_type => self.class.to_s))
  end

  def self.aggregate_size
    self.sum('total_file_size')
  end

  def sibling_file_groups
    self.collection.file_groups.order(:name).all - [self]
  end

  def supported_event_hash
    @@supported_event_hash ||= read_event_hash(:file_group)
  end

  def supported_scheduled_event_hash
    @@supported_scheduled_event_hash ||= read_scheduled_event_hash(:file_group)
  end

  def canonicalize_cfs_root
    self.cfs_root = nil if self.cfs_root.blank? or !self.supports_cfs
  end

  def strip_fields
    self.staged_file_location.try(:strip!)
  end

  #override in subclasses that do
  def supports_cfs
    false
  end

  #override (e.g. by association) in subclasses that do support cfs
  def cfs_directory
    nil
  end

  def potential_target_file_groups
    self.collection.file_groups.where(:type => self.class.downstream_types)
  end

  #subclasses override this to give a list that contains the potential downstream classes for relating filegroups
  def self.downstream_types
    raise RuntimeError, 'SubclassResposibility'
  end

  def has_target?(file_group)
    self.target_file_groups.include?(file_group)
  end

  def target_relation_note(file_group)
    self.target_file_group_joins.where(:target_file_group_id => file_group.id).first.try(:note)
  end

  def source_relation_note(file_group)
    self.source_file_group_joins.where(:source_file_group_id => file_group.id).first.try(:note)
  end

  def repository
    self.collection.repository
  end

  def nullify_cfs_directory
    self.cfs_directory_id = nil
  end

  def incomplete_scheduled_events
    self.scheduled_events.where("state != 'completed'")
  end

  #override this as needed for subclasses. Size should be in GB. Should use this method rather than the db column to
  #read this value.
  def file_size
    self.total_file_size || 0
  end

  #override as needed for subclasses. Should use this method rather than the db column to read this value.
  def file_count
    self.total_files || 0
  end

  def initialize_file_info
    self.total_files ||= 0
    self.total_file_size ||= 0
  end

  def public?
    self.rights_declaration.public?
  end

end