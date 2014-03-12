class BitLevelFileGroup < FileGroup
  include RedFlagAggregator

  #after_save :schedule_create_cfs_file_infos
  has_many :virus_scans, :dependent => :destroy, :foreign_key => :file_group_id

  #aggregates_red_flags :self => :cfs_red_flags, :label_method => :name

  belongs_to :cfs_directory

  def storage_level
    'bit-level store'
  end

  def self.downstream_types
    ['ObjectLevelFileGroup']
  end

  def supports_cfs
    true
  end

  def full_cfs_directory_path
    raise RuntimeError, "No cfs directory set for file group #{self.id}" unless self.cfs_directory.present?
    File.join(CfsRoot.instance.path, self.cfs_directory.path)
  end

  #make sure that there is a CfsFile object at the supplied absolute path and return it
  def ensure_file_at_absolute_path(path)
    self.cfs_directory.ensure_file_at_absolute_path(path)
  end
  #
  ##It's possible that the string concatenation here is a postgresism, though I think
  ##it is SQL99 standard
  ##We check both the case that there is a file group that has exactly this path and then
  ##look for one where cfs_root/ is a prefix of the provided path (we need to add the trailing slash
  ## in this case or else we could have multiple possibilities, e.g. root/1 and root/19 would both match root/1/subdir/file.ext)
  #def self.for_cfs_path(path)
  #  return nil if path.blank?
  #  return self.where(:cfs_root => path).first || self.where("? LIKE cfs_root || '/%'", path).first
  #end
  #
  #def schedule_create_cfs_file_infos
  #  return unless self.cfs_root_changed?
  #  self.delay.create_cfs_file_infos
  #end
  #
  #def create_cfs_file_infos
  #  Cfs.ensure_basic_assessment_for_tree(self.cfs_root)
  #end
  #
  #def remove_cfs_file_info_orphans
  #  CfsFileInfo.remove_orphans(self.cfs_root)
  #end
  #
  #def cfs_update_file_characteristics
  #  return unless self.cfs_root
  #  self.total_files = self.cfs_file_infos.count
  #  self.total_file_size = self.cfs_file_infos.sum(:size) / 1.gigabyte
  #  self.save!
  #end
  #
  #def cfs_file_infos
  #  CfsFileInfo.all_for_path(self.cfs_root) if self.cfs_root
  #end
  #
  #def cfs_red_flags
  #  return [] unless self.cfs_root
  #  RedFlag.where(:red_flaggable_type => 'CfsFileInfo').
  #      joins('JOIN cfs_file_infos ON red_flags.red_flaggable_id = cfs_file_infos.id').
  #      where('cfs_file_infos.path LIKE ?', self.cfs_root + '/%').load
  #end

end