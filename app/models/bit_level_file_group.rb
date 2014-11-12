class BitLevelFileGroup < FileGroup
  include RedFlagAggregator

  has_many :virus_scans, dependent: :destroy, foreign_key: :file_group_id

  aggregates_red_flags self: :cfs_red_flags, label_method: :name

  belongs_to :cfs_directory

  has_many :job_fits_directories, class_name: 'Job::FitsDirectory', foreign_key: :file_group_id
  has_many :job_cfs_initial_directory_assessments, class_name: 'Job::CfsInitialDirectoryAssessment', foreign_key: :file_group_id

  after_save :handle_cfs_assessment

  def create_cfs_file_infos
    #TODO nothing - exists to clear some delayed jobs, then delete this method
  end

  def storage_level
    'bit-level store'
  end

  def self.downstream_types
    ['ObjectLevelFileGroup']
  end

  def self.having_cfs_directory
    where('cfs_directory_id is not null')
  end

  def supports_cfs
    true
  end

  def full_cfs_directory_path
    raise RuntimeError, "No cfs directory set for file group #{self.id}" unless self.cfs_directory.present?
    File.join(CfsRoot.instance.path, self.cfs_directory.path)
  end

  def expected_absolute_cfs_root_directory
    File.join(CfsRoot.instance.path, self.expected_relative_cfs_root_directory)
  end

  def expected_relative_cfs_root_directory
    File.join(self.collection_id.to_s, self.id.to_s)
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

  def handle_cfs_assessment
    #If the file group had a present value for cfs_directory_id before saving
    #and it changed, then cancel the jobs in the old assessment. It is important
    #to do it in this order.
    if self.cfs_directory_id_was.present? and self.cfs_directory_id_changed?
      Job::CfsInitialFileGroupAssessment.where(file_group_id: self.id).each do |assessment|
        assessment.destroy_queued_jobs_and_self
      end
      Job::CfsInitialDirectoryAssessment.where(file_group_id: self.id, cfs_directory_id: self.cfs_directory_id_was).each do |assessment|
        assessment.destroy_queued_jobs_and_self
      end
    end
    #If the file group has a new, present value for cfs_directory_id
    # then schedule the cfs_assessment.
    if self.cfs_directory_id.present? and self.cfs_directory_id_changed?
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
    RedFlag.where(red_flaggable_type: 'CfsFile').
        joins('JOIN cfs_files ON red_flags.red_flaggable_id = cfs_files.id').
        where(cfs_files: {cfs_directory_id: self.cfs_directory.recursive_subdirectory_ids})
  end

  def file_size
    return 0 unless self.cfs_directory
    size = self.cfs_directory.tree_size / 1.gigabyte
    if self.total_file_size != size
      self.total_file_size = size
      self.save!
    end
    return size
  end

  def file_count
    return 0 unless self.cfs_directory
    count = self.cfs_directory.tree_count
    if self.total_files != count
      self.total_files = count
      self.save!
    end
    return count
  end

  def amazon_backups
    if self.cfs_directory.present?
      self.cfs_directory.amazon_backups
    else
      []
    end
  end

  def last_amazon_backup
    self.amazon_backups.first
  end

  def self.update_cached_file_stats
    self.all.each do |file_group|
      file_group.file_count
      file_group.file_size
    end
  end

  def is_currently_assessable?
    !(Job::CfsInitialFileGroupAssessment.where(file_group_id: self.id).first or
        Job::CfsInitialDirectoryAssessment.where(file_group_id: self.id).first)
  end

end