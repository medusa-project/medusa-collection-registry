class BitLevelFileGroup < FileGroup
  include RedFlagAggregator

  has_many :virus_scans, :dependent => :destroy, :foreign_key => :file_group_id

  aggregates_red_flags :self => :cfs_red_flags, :label_method => :name

  belongs_to :cfs_directory
  has_many :job_fits_directories, :class_name => 'Job::FitsDirectory', foreign_key: :file_group_id
  has_many :job_cfs_initial_directory_assessments, :class_name => 'Job::CfsInitialDirectoryAssessment', foreign_key: :file_group_id

  after_save :maybe_schedule_initial_cfs_assessment

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

  #Find the cfs directory at the path relative to the cfs directory root path for this file group
  #i.e. CfsRoot.path + self.cfs_directory.path
  def cfs_directory_at_path(path)
    self.cfs_directory.find_directory_at_relative_path(path)
  end

  #Find the cfs file at the path relative to the cfs directory root path for this file group
  #i.e. CfsRoot.path + self.cfs_directory.path
  def cfs_file_at_path(path)
    self.cfs_directory.find_file_at_relative_path(path)
  end

  #If the file group has a new, present value for cfs_directory_id and
  #an old, blank one then schedule the cfs_assessment.
  def maybe_schedule_initial_cfs_assessment
    if self.cfs_directory_id.present? and self.cfs_directory_id_changed? and
        self.cfs_directory_id_was.blank?
      self.schedule_initial_cfs_assessment
    end
  end

  def schedule_initial_cfs_assessment
    Job::CfsInitialFileGroupAssessment.create_for(self)
  end

  def run_initial_cfs_assessment
    self.cfs_directory.make_initial_tree
    self.cfs_directory.schedule_initial_assessments
  end

  def running_fits_file_count
    Job::FitsDirectory.where(file_group_id: self.id).sum(:file_count)
  end

  def running_initial_assessments_file_count
    Job::CfsInitialDirectoryAssessment.where(file_group_id: self.id).sum(:file_count)
  end

  def cfs_red_flags
    return [] unless self.cfs_directory
    RedFlag.where(:red_flaggable_type => 'CfsFile').
        joins('JOIN cfs_files ON red_flags.red_flaggable_id = cfs_files.id').
        where(:cfs_files => {:cfs_directory_id => self.cfs_directory.recursive_subdirectory_ids})
  end

end