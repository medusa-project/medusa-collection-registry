class Job::CfsInitialFileGroupAssessment < ActiveRecord::Base
  belongs_to :file_group

  def self.create_for(file_group)
    Delayed::Job.enqueue(self.create(file_group: file_group), priority: 60) unless self.find_by(file_group_id: file_group.id)
  end

  def perform
    self.file_group.run_initial_cfs_assessment
  end

  def success(job)
    self.destroy
  end

end