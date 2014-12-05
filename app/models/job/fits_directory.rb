class Job::FitsDirectory < Job::Base

  belongs_to :file_group, touch: true
  belongs_to :cfs_directory, touch: true
  has_many :job_fits_directories, :class_name => 'Job::FitsDirectory'

  def self.create_for(cfs_directory)
    Delayed::Job.enqueue(self.create(cfs_directory: cfs_directory, file_group: cfs_directory.owning_file_group,
                                     file_count: cfs_directory.cfs_files.count),
                         priority: 70)
  end

  def perform
    self.cfs_directory.run_fits
  end

end
