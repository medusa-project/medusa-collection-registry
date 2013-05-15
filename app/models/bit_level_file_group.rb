class BitLevelFileGroup < FileGroup
  include RedFlagAggregator

  after_save :schedule_create_cfs_file_infos
  has_many :virus_scans, :dependent => :destroy, :foreign_key => :file_group_id

  aggregates_red_flags :self => :cfs_red_flags, :label_method => :name, :path_method => :file_group_path

  def storage_level
    'bit-level store'
  end

  def supports_cfs
    true
  end

  #It's possible that the string concatenation here is a postgresism, though I think
  #it is SQL99 standard
  def self.for_cfs_path(path)
    return nil if path.blank?
    return self.where("? LIKE cfs_root || '%'", path).first
  end

  def schedule_create_cfs_file_infos
    return unless self.cfs_root_changed?
    self.delay.create_cfs_file_infos
  end

  def create_cfs_file_infos
    Cfs.ensure_basic_assessment_for_tree(self.cfs_root)
  end

  def remove_cfs_file_info_orphans
    CfsFileInfo.remove_orphans(self.cfs_root)
  end

  def cfs_update_file_characteristics
    return unless self.cfs_root
    self.total_files = self.cfs_file_infos.count
    self.total_file_size = self.cfs_file_infos.sum(:size) / 1.gigabyte
    self.save!
  end

  def cfs_file_infos
    CfsFileInfo.all_for_path(self.cfs_root) if self.cfs_root
  end

  #TODO - I expect all this original bit level stuff should disappear with the CFS in place
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

  def ensure_fits_xml_for_owned_bit_files
    self.each_bit_file do |bit_file|
      bit_file.delay(:priority => 60).ensure_fits_xml if bit_file.dx_ingested and bit_file.fits_xml.blank?
    end
  end

  #do block to each bit file owned by this file group
  def each_bit_file
    return unless self.root_directory
    #find all directories
    owned_directories_ids = self.root_directory.descendant_directory_ids << self.root_directory.id
    #find all bit files and yield block to them. Use find_each because this could be a large set
    BitFile.where(:directory_id => owned_directories_ids).find_each do |bit_file|
      yield bit_file
    end
  end

  def cfs_red_flags
    return [] unless self.cfs_root
    RedFlag.where(:red_flaggable_type => 'CfsFileInfo').
        joins("JOIN cfs_file_infos ON red_flags.red_flaggable_id = cfs_file_infos.id").
        where('cfs_file_infos.path LIKE ?', self.cfs_root + "%").all
  end

end