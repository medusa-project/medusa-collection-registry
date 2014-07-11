class Job::AmazonBackup < Job::Base

  #We should only be able to have one of these at a time for a given backup
  validates_uniqueness_of :amazon_backup_id

  def self.create_for(amazon_backup)
    Delayed::Job.enqueue(self.create(amazon_backup_id: amazon_backup.id), :queue => 'glacier')
  end

  def perform
    self.amazon_backup.request_backup
  end

  #I had a problem doing this an a association - I don't know why
  def amazon_backup
    AmazonBackup.find(self.amazon_backup_id)
  end

end