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
    Delayed::Job.all.select {|job| YAML.unsafe_load(job.handler) == self}
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
    self.delayed_jobs.select{|j| j.attempts > 0}.each do |job|
      job.attempts = job.attempts - 1
      job.run_at = Time.now
      job.locked_at = nil
      job.locked_by = nil
      job.last_error = nil
      job.save!
    end
  end

  def enqueue_job(args = {})
    Delayed::Job.enqueue(self, args.reverse_merge(queue: queue, priority: priority))
  end

  #Override in subclasses as appropriate
  def queue
    Settings.delayed_job.default_queue
  end

  #Override in subclasses as appropriate
  def priority
    Settings.delayed_job.priority.base_job
  end

end
