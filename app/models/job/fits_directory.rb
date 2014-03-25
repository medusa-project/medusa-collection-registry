class Job::FitsDirectory < ActiveRecord::Base

  belongs_to :file_group
    belongs_to :cfs_directory

    def self.create_for(cfs_directory)
      Delayed::Job.enqueue(self.new(cfs_directory: cfs_directory, file_group: cfs_directory.owning_file_group,
                           file_count: cfs_directory.cfs_files.count),
                           priority: 70)
    end

    def perform
      self.cfs_directory.run_fits
    end

end
