class Job::AmazonBackup < Job::Base

  #We should only be able to have one of these at a time for a given backup
  validates_presence_of :amazon_backup_id
  validates_uniqueness_of :amazon_backup_id, allow_blank: false

  def self.create_for(amazon_backup)
    Delayed::Job.enqueue(self.create(amazon_backup_id: amazon_backup.id), queue: 'glacier')
  end

  def perform
    if self.amazon_backup.cfs_directory
      self.amazon_backup.request_backup
    end
  end

  #I had a problem doing this an a association - I don't know why. Maybe because the unnamespace qualified names are the same?
  def amazon_backup
    AmazonBackup.find(self.amazon_backup_id)
  end

end