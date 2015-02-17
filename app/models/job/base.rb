class Job::Base < ActiveRecord::Base

  self.abstract_class = true

  def destroy_queued_jobs_and_self
    self.delayed_jobs.each do |job|
      job.destroy
    end
    self.destroy
  end

  def delayed_jobs
    Delayed::Job.where("handler LIKE '#{self.delayed_job_handler_prefix}%'").all
  end

  #The way delayed job currently stores the handler we have to look it up with just the prefix
  #of the YAML representation
  def delayed_job_handler_prefix
    self.to_yaml.lines[0..2].join
  end

  def success(job)
    self.destroy!
  end

  def error(job, exception)
    notify_on_error(job, exception)
  end

  def failure(job)
    notify_on_error(job, nil)
  end

  def notify_on_error(job, exception = nil)
    DelayedJobErrorMailer.error(job, exception).deliver if job.attempts >= 5
  end

end