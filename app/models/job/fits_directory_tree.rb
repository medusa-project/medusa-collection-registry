class Job::FitsDirectoryTree < ActiveRecord::Base

  belongs_to :file_group
  belongs_to :cfs_directory

  def self.create_for(cfs_directory)
    Delayed::Job.enqueue(self.new(cfs_directory: cfs_directory, file_group: cfs_directory.owning_file_group),
                         priority: 60)
  end

  def perform
    self.cfs_directory.schedule_fits
  end

end
