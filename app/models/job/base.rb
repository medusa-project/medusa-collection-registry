class Job::Base < ApplicationRecord

  self.abstract_class = true

  def destroy_queued_jobs_and_self
    destroy_queued_jobs
    self.destroy
  end

  def destroy_queued_jobs
    self.delayed_jobs.each do |job|
      job.destroy
    end
  end

  def delayed_jobs
    Delayed::Job.all.select {|job| YAML.load(job.handler) == self}
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
    DelayedJobErrorMailer.error(job, exception).deliver_now if job.attempts >= 5
  end

  #to be used manually when there is a failure to get the jobs to retry immediately
  def reset_delayed_jobs
    self.delayed_jobs.where('attempts > 0').each do |job|
      job.attempts = job.attempts - 1
      job.run_at = Time.now
      job.save!
    end
  end

end
