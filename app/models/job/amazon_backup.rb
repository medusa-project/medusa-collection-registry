class Job::AmazonBackup < Job::Base

  belongs_to :amazon_backup, class_name: '::AmazonBackup'

  #We should only be able to have one of these at a time for a given backup
  validates_presence_of :amazon_backup_id
  validates_uniqueness_of :amazon_backup_id, allow_blank: false

  def self.create_for(amazon_backup, job_opts = {})
    Delayed::Job.enqueue(self.create!(amazon_backup_id: amazon_backup.id), {queue: 'default'}.merge(job_opts))
  end

  def perform
    if self.amazon_backup.cfs_directory
      self.amazon_backup.request_backup
    end
  end

end