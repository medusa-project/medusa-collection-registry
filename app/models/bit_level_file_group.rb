require 'fileutils'
require 'set'
class BitLevelFileGroup < FileGroup

  has_many :job_cfs_initial_directory_assessments, class_name: 'Job::CfsInitialDirectoryAssessment', foreign_key: :file_group_id
  has_many :archived_accrual_jobs, dependent: :destroy, foreign_key: :file_group_id

  after_create :ensure_cfs_directory
  after_destroy :maybe_destroy_cfs_directories
  before_destroy :check_emptiness

  delegate :ensure_file_at_relative_path, :find_directory_at_relative_path,
           :find_file_at_relative_path, to: :cfs_directory

  def ensure_cfs_directory
    physical_cfs_directory_path = expected_absolute_cfs_root_directory
    FileUtils.mkdir_p(physical_cfs_directory_path) unless Dir.exists?(physical_cfs_directory_path)
    if cfs_directory = CfsDirectory.find_by(path: expected_relative_cfs_root_directory)
      self.cfs_directory_id = cfs_directory.id unless self.cfs_directory_id
      self.save!
    else
      cfs_directory = CfsDirectory.create!(path: expected_relative_cfs_root_directory)
      self.cfs_directory_id = cfs_directory.id unless self.cfs_directory_id
      self.save!
    end
  end

  #Destroy the physical cfs directory and/or CfsDirectory corresponding to this
  #ONLY IF they are empty
  def maybe_destroy_cfs_directories
    physical_cfs_directory_path = expected_absolute_cfs_root_directory
    if Dir.exist?(physical_cfs_directory_path) and (Dir.entries(physical_cfs_directory_path).to_set == %w(. ..).to_set)
      Dir.unlink(physical_cfs_directory_path) rescue nil
    end
    if cfs_directory.try(:is_empty?)
      cfs_directory.destroy
    end
  end

  def storage_level
    'bit-level store'
  end

  def self.downstream_types
    []
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

  def schedule_initial_cfs_assessment
    Job::CfsInitialFileGroupAssessment.create_for(self)
  end

  def run_initial_cfs_assessment
    self.cfs_directory.make_and_assess_tree
  end

  def running_initial_assessments_file_count
    Job::CfsInitialDirectoryAssessment.where(file_group_id: self.id).sum(:file_count)
  end

  def pristine?
    return true unless cfs_directory.present?
    return cfs_directory.pristine?
  end

  def file_size
    total_file_size
  end

  def file_count
    total_files
  end

  def amazon_backups
    self.cfs_directory.present? ? self.cfs_directory.amazon_backups : []
  end

  def last_amazon_backup
    self.amazon_backups.first
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
    self.cfs_directory.reload if self.cfs_directory.present?
  end

  def accrual_unstarted?
    events.where(key: 'files_added').blank? and
        (cfs_directory.blank? or cfs_directory.pristine?)
  end

  def check_emptiness
    unless pristine?
      errors.add(:base, 'This file group has content and cannot be deleted. Please contact Medusa administrators to have it removed.')
      return false
    end
    return true
  end

  def self.aggregate_size
    sum('total_file_size')
  end

  def after_restore
    Sunspot.index self
    events.find_each do |event|
      event.recascade
    end
    events.reset
    cfs_directory.after_restore
  end

  def content_type_summary(start, count)
    self.class.connection.select_all("select * from file_group_content_type_report(#{id}, #{start.to_i}, #{count.to_i})").to_hash
  end

end