class SetDefaultQueueForDelayedJobs < ActiveRecord::Migration
  def change
    Delayed::Job.all.each do |job|
      job.queue ||= 'default'
      job.save!
    end
  end
end
