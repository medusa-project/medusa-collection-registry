class Job::CfsInitialFileGroupAssessment < ActiveRecord::Base
  belongs_to :file_group

  def self.create_for(file_group)
    Delayed::Job.enqueue(self.new(file_group: file_group), priority: 60)
  end

  def perform
    self.file_group.run_initial_cfs_assessment
  end

  def success(job)
    self.destroy
  end

end