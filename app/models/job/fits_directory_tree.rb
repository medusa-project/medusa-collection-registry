class Job::FitsDirectoryTree < Job::Base

  belongs_to :file_group, touch: true
  belongs_to :cfs_directory, touch: true

  def self.create_for(cfs_directory)
    Delayed::Job.enqueue(self.create(cfs_directory: cfs_directory, file_group: cfs_directory.file_group),
                         priority: 60)
  end

  def perform
    self.cfs_directory.schedule_fits
  end

end
