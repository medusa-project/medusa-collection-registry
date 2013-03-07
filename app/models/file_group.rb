class FileGroup < ActiveRecord::Base
  attr_accessible :collection_id, :external_file_location,
                  :producer_id, :file_type_id, :summary, :provenance_note,
                  :collection_attributes, :rights_declaration_attributes,
                  :name, :storage_level, :staged_file_location, :total_file_size,
                  :file_format, :total_files, :related_file_group_ids
  belongs_to :collection
  belongs_to :producer
  belongs_to :file_type
  belongs_to :root_directory, :class_name => 'Directory'
  has_one :rights_declaration, :dependent => :destroy, :autosave => true, :as => :rights_declarable
  has_many :assessments, :as => :assessable, :dependent => :destroy
  has_many :related_file_group_joins, :dependent => :destroy
  has_many :related_file_groups, :through => :related_file_group_joins, :order => 'name'
  accepts_nested_attributes_for :collection, :rights_declaration

  before_validation :ensure_rights_declaration

  STORAGE_LEVELS = ['external', 'bit-level store', 'object-level store']

  validates_uniqueness_of :root_directory_id, :allow_nil => true
  validates_presence_of :name
  validates_inclusion_of :storage_level, :in => STORAGE_LEVELS

  def file_type_name
    self.file_type.try(:name)
  end

  #set the file group ids, making sure any removed ids have their joins and the
  #symmetric joins both destroyed
  def symmetric_update_related_file_groups(related_ids, notes)
    current_related_file_groups = self.related_file_groups
    new_related_file_groups = self.class.find(related_ids)
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
    collection_rights = self.collection.rights_declaration
    self.build_rights_declaration(:rights_basis => collection_rights.rights_basis, :copyright_jurisdiction => collection_rights.copyright_jurisdiction,
                                  :copyright_statement => collection_rights.copyright_statement, :access_restrictions => collection_rights.access_restrictions)
  end

  def self.aggregate_size
    self.sum('total_file_size')
  end

  def bit_ingest(source_directory, opts = {})
    #make sure we have a root directory and that it matches up with the passed source
    #directory
    root_name = File.basename(source_directory)
    root_dir = self.root_directory(true)
    if root_dir
      unless root_name == root_dir.name
        raise RuntimeError, "Name of file group ingest directory has changed."
      end
    else
      root_dir = self.collection.make_file_group_root(root_name, self)
    end
    #do the ingest if things check out
    root_dir.bit_ingest(source_directory, opts)
  end

  def bit_export(target_directory, opts = {})
    self.root_directory(true).bit_export(target_directory, opts)
  end

  def bit_recursive_delete
    if self.root_directory(true)
      self.root_directory.recursive_delete(true)
      self.root_directory = nil
      self.save
    end
  end

  def assessable_label
    "File Group #{self.id}"
  end

  def sibling_file_groups
    self.collection.file_groups.order(:name).all - [self]
  end

  def relation_note(related_file_group)
    join = self.related_file_group_join(related_file_group)
    join ? join.note : ''
  end

  def ensure_fits_xml_for_owned_bit_files
    self.each_bit_file do |bit_file|
      bit_file.delay.ensure_fits_xml
    end
  end

  #do block to each bit file owned by this file group
  def each_bit_file
    #find all directories
    owned_directories_ids = self.root_directory.descendant_directory_ids << self.root_directory.id
    #find all bit files and yield block to them. Use find_each because this could be a large set
    BitFile.where(:directory_id => owned_directories_ids).find_each do |bit_file|
      yield bit_file
    end
  end

end