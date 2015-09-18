class Job::CfsInitialFileGroupAssessment < Job::Base
  belongs_to :file_group

  def self.create_for(file_group)
    raise RuntimeError, "No cfs directory defined for file group #{file_group.id}. Cannot create assessment job." unless file_group.cfs_directory.present?
    Delayed::Job.enqueue(self.create!(file_group: file_group), priority: 60, queue: 'initial_assessment') unless self.find_by(file_group_id: file_group.id)
  end

  def perform
    raise RuntimeError, "No cfs directory defined for file group #{self.file_group.id}. Cannot run assessment job." unless self.file_group.cfs_directory.present?
    self.file_group.run_initial_cfs_assessment
  end

end