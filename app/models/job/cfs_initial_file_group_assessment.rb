class Job::CfsInitialFileGroupAssessment < Job::Base
  belongs_to :file_group

  def self.create_for(file_group)
    raise RuntimeError, "No cfs directory defined for file group #{file_group.id}. Cannot create assessment job." unless file_group.cfs_directory.present?
    unless self.find_by(file_group_id: file_group.id)
      job = self.create!(file_group: file_group)
      job.enqueue_job
    end
  end

  def queue
    Settings.delayed_job.initial_assessment_queue
  end

  def priority
    Settings.delayed_job.priority.cfs_initial_file_group_assessment
  end

  def perform
    raise RuntimeError, "No cfs directory defined for file group #{self.file_group.id}. Cannot run assessment job." unless self.file_group && self.file_group.cfs_directory.present?
    self.file_group.run_initial_cfs_assessment
  end

end