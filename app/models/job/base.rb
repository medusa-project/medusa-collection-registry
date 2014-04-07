class Job::Base < ActiveRecord::Base

  self.abstract_class = true

  def destroy_queued_jobs_and_self
    Delayed::Job.where(handler: self.to_yaml).all.each do |job|
      job.destroy
    end
    self.destroy
  end

end