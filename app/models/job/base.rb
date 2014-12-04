class Job::Base < ActiveRecord::Base

  self.abstract_class = true

  def destroy_queued_jobs_and_self
    self.delayed_jobs.each do |job|
      job.destroy
    end
    self.destroy
  end

  def delayed_jobs
    Delayed::Job.where(handler: self.to_yaml).all
  end

  def success(job)
    self.destroy!
  end

end