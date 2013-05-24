class FileGroup < ActiveRecord::Base
  include Eventable

  attr_accessible :collection_id, :external_file_location,
                  :producer_id, :file_type_id, :summary, :provenance_note,
                  :name, :staged_file_location, :total_file_size,
                  :file_format, :total_files, :related_file_group_ids, :cfs_root

  belongs_to :collection
  belongs_to :producer
  belongs_to :file_type
  belongs_to :root_directory, :class_name => 'Directory'
  has_one :rights_declaration, :dependent => :destroy, :autosave => true, :as => :rights_declarable
  has_many :assessments, :as => :assessable, :dependent => :destroy
  has_many :related_file_group_joins, :dependent => :destroy
  has_many :related_file_groups, :through => :related_file_group_joins, :order => 'name'
  has_many :events, :as => :eventable, :dependent => :destroy, :order => 'date DESC'

  before_validation :ensure_rights_declaration
  before_save :canonicalize_cfs_root

  validates_uniqueness_of :root_directory_id, :allow_nil => true
  validates_uniqueness_of :cfs_root, :allow_blank => true
  validates_presence_of :name

  STORAGE_LEVEL_HASH = {'ExternalFileGroup' => 'external',
                        'BitLevelFileGroup' => 'bit-level store',
                        'ObjectLevelFileGroup' => 'object-level store'}
  STORAGE_LEVELS = STORAGE_LEVEL_HASH.values

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

  #set the file group ids, making sure any removed ids have their joins and the
  #symmetric joins both destroyed
  def symmetric_update_related_file_groups(related_ids, notes)
    current_related_file_groups = self.related_file_groups
    new_related_file_groups = FileGroup.find(related_ids)
    (current_related_file_groups - new_related_file_groups).each do |deleted_file_group|
      join = related_file_group_join(deleted_file_group)
      join.destroy if join
    end
    self.related_file_group_ids = related_ids
    related_ids.each do |id|
      if notes[id]
        join = related_file_group_join(id)
        if join
          join.note = notes[id]
          join.save!
        end
      end
    end
  end

  def related_file_group_join(related_file_group_or_id)
    id = related_file_group_or_id.is_a?(FileGroup) ? related_file_group_or_id.id : related_file_group_or_id
    RelatedFileGroupJoin.where(:file_group_id => self.id, :related_file_group_id => id).first
  end

  def related_to?(file_group)
    self.related_file_groups.include?(file_group)
  end

  def ensure_rights_declaration
    self.rights_declaration ||= self.clone_collection_rights_declaration
  end

  def clone_collection_rights_declaration
    self.build_rights_declaration(self.collection.rights_declaration.attributes.slice(
                                      :rights_basis, :copyright_jurisdiction, :copyright_statement, :access_restrictions))
  end

  def self.aggregate_size
    self.sum('total_file_size')
  end

  def sibling_file_groups
    self.collection.file_groups.order(:name).all - [self]
  end

  def relation_note(related_file_group)
    join = self.related_file_group_join(related_file_group)
    join ? join.note : ''
  end

  def supported_event_hash
    @@supported_event_hash ||= read_event_hash(:file_group)
  end

  def canonicalize_cfs_root
    self.cfs_root = nil if self.cfs_root.blank? or !self.supports_cfs
  end

  #override in subclasses that do
  def supports_cfs
    false
  end

end