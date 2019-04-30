class Job::CfsInitialDirectoryAssessment < Job::Base
    belongs_to :file_group
    belongs_to :cfs_directory

    validates_uniqueness_of :cfs_directory

    def self.create_for(cfs_directory, file_group)
      unless self.find_by(cfs_directory_id: cfs_directory.id)
        job = self.create!(cfs_directory: cfs_directory, file_group: file_group,
                                    file_count: cfs_directory.cfs_files.count)
        job.enqueue_job
      end
    end

    def queue
      Settings.delayed_job.initial_assessment_queue
    end

    def priority
      Settings.delayed_job.priority.cfs_initial_directory_assessment
    end

    def perform
      self.cfs_directory.run_initial_assessment if self.cfs_directory
    rescue MedusaStorage::Error::InvalidDirectory
      #do nothing - the directory does not exist, so just let this job expire
    end

    def self.for_repository(repository)
      joins(file_group: {collection: :repository}).where('repositories.id = ?', repository.id)
    end

    def self.file_groups_for_repository(repository)
      BitLevelFileGroup.where(id: for_repository(repository).distinct.pluck(:file_group_id)).includes(:cfs_directory)
    end

end