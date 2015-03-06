class BitLevelFileGroup < FileGroup
  include RedFlagAggregator

  has_many :virus_scans, dependent: :destroy, foreign_key: :file_group_id

  aggregates_red_flags self: :cfs_red_flags, label_method: :title

  has_many :job_fits_directories, class_name: 'Job::FitsDirectory', foreign_key: :file_group_id
  has_many :job_cfs_initial_directory_assessments, class_name: 'Job::CfsInitialDirectoryAssessment', foreign_key: :file_group_id

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

  def ensure_file_at_relative_path(path)
    self.cfs_directory.ensure_file_at_relative_path(path)
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
    return total_file_size
  end

  def refresh_file_size
    return unless self.cfs_directory(true)
    size = self.cfs_directory.tree_size / 1.gigabyte
    if self.total_file_size != size
      self.total_file_size = size
      self.save!
    end
  end

  def file_count
    return total_files
  end

  def refresh_file_count
    return unless self.cfs_directory(true)
    count = self.cfs_directory.tree_count
    if self.total_files != count
      self.total_files = count
      self.save!
    end
  end

  def refresh_file_stats
    self.refresh_file_size
    self.refresh_file_count
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
      file_group.refresh_file_stats
    end
  end

  def is_currently_assessable?
    !(Job::CfsInitialFileGroupAssessment.find_by(file_group_id: self.id) or
        Job::CfsInitialDirectoryAssessment.find_by(file_group_id: self.id))
  end

  def cfs_directory_id
    cfs_directory.try(:id)
  end

  def cfs_directory_id=(cfs_directory_id)
    old_cfs_directory = self.cfs_directory
    new_cfs_directory = (CfsDirectory.find(cfs_directory_id) rescue nil)
    #just return if there is no change
    return if new_cfs_directory.blank? and old_cfs_directory.blank?
    return if old_cfs_directory == new_cfs_directory
    transaction do
      if old_cfs_directory
        old_cfs_directory.parent = nil
        old_cfs_directory.save!
      end
      if new_cfs_directory
        new_cfs_directory.parent = self
        new_cfs_directory.save!
      end
    end
    self.cfs_directory(true)
  end

  #return a hash with key the id
  #values are hashes with title, collection id and title, repository id and title, total file size and count,
  #last backup date (or nil) and last backup completed (or nil)
  def self.dashboard_amazon_info
    backup_info_hash = file_group_latest_amazon_backup_hash
    file_group_info_query = <<SQL
    SELECT FG.id, FG.title, FG.total_files, FG.total_file_size, C.id AS collection_id, C.title AS collection_title,
           R.id AS repository_id, R.title AS repository_title
    FROM file_groups FG, collections C, repositories R, cfs_directories CFS
    WHERE FG.type = 'BitLevelFileGroup' AND FG.collection_id = C.id AND c.repository_id = R.id
    AND CFS.parent_type = 'FileGroup' AND CFS.parent_id = FG.id
    ORDER BY FG.id ASC
SQL
    file_groups = connection.select_all(file_group_info_query).to_hash.collect {|h| h.with_indifferent_access}
    Hash.new.tap do |hash|
      file_groups.each do |file_group|
        id = file_group[:id].to_i
        hash[id] = file_group
        if backup_info = backup_info_hash[id]
          file_group[:backup_date] = backup_info[:date]
          file_group[:backup_completed] = backup_info[:completed] ? 'Yes' : 'No'
        else
          file_group[:backup_date] = 'None'
          file_group[:backup_completed] = 'N/A'
        end
      end
    end
  end

  #hash from file_group_id to hash with latest backup date and whether it is complete, as judged from the part_count
  #and archive_ids
  def self.file_group_latest_amazon_backup_hash
    query = <<SQL
    SELECT FG.id AS file_group_id, AB.part_count, AB.archive_ids, AB.date FROM amazon_backups AB,
    (SELECT cfs_directory_id, MAX(date) AS max_date FROM amazon_backups GROUP BY cfs_directory_id) ABLU,
    cfs_directories CFS, file_groups FG
    WHERE AB.cfs_directory_id = ABLU.cfs_directory_id AND AB.date = ABLU.max_date AND AB.part_count IS NOT NULL
    AND AB.archive_ids IS NOT NULL AND CFS.id = AB.cfs_directory_id
    AND FG.id = CFS.parent_id AND CFS.parent_type = 'FileGroup'
SQL
    backups = connection.select_rows(query)
    Hash.new.tap do |hash|
      backups.each do |file_group_id, part_count, archive_ids, date|
        hash[file_group_id.to_i] = HashWithIndifferentAccess.new.tap do |backup_hash|
          backup_hash[:date] = date
          archives = YAML.load(archive_ids)
          backup_hash[:completed] = (archives.present? && (archives.size == part_count.to_i) && archives.none? {|id| id.blank?})
        end
      end
    end
  end


end