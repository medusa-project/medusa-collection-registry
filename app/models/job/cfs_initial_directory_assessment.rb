class Job::CfsInitialDirectoryAssessment < ActiveRecord::Base
  belongs_to :file_group
  belongs_to :cfs_directory

  def self.create_for(cfs_directory, file_group)
    Delayed::Job.enqueue(self.new(cfs_directory: cfs_directory, file_group: file_group,
                                  file_count: cfs_directory.cfs_files.count),
                         priority: 70)
  end

  def perform
    self.cfs_directory.run_initial_assessment
  end

  def success(job)
    self.destroy
  end

end