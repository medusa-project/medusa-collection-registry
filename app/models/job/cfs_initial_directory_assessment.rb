class Job::CfsInitialDirectoryAssessment < Job::Base
    belongs_to :file_group
    belongs_to :cfs_directory

    def self.create_for(cfs_directory, file_group)
      Delayed::Job.enqueue(self.create!(cfs_directory: cfs_directory, file_group: file_group,
                                       file_count: cfs_directory.cfs_files.count),
                           priority: 70, queue: 'initial_assessment') unless self.find_by(cfs_directory_id: cfs_directory.id)
    end

    def perform
      self.cfs_directory.run_initial_assessment if self.cfs_directory
    end

    def self.for_repository(repository)
      joins(file_group: {collection: :repository}).where('repositories.id = ?', repository.id)
    end

    def self.file_groups_for_repository(repository)
      BitLevelFileGroup.where(id: for_repository(repository).distinct.pluck(:file_group_id)).includes(:cfs_directory)
    end

end