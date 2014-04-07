class Job::CfsInitialDirectoryAssessment < Job::Base
  belongs_to :file_group
  belongs_to :cfs_directory

  def self.create_for(cfs_directory, file_group)
    Delayed::Job.enqueue(self.create(cfs_directory: cfs_directory, file_group: file_group,
                                  file_count: cfs_directory.cfs_files.count),
                         priority: 70) unless self.find_by(cfs_directory_id: cfs_directory.id)
  end

  def perform
    self.cfs_directory.run_initial_assessment
  end

  def success(job)
    self.destroy
  end

end