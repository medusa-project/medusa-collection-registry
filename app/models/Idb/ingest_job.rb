class Idb::IngestJob < Job::Base

  def self.create_for(message)
    job = self.create!(staging_path: message['staging_path'])
    Delayed::Job.enqueue(job)
  end

  def perform
    ensure_uuid
    ensure_directories
    #rsync file
    #add cfs file object
    #schedule assessments
  end

  def success(job)
    #send return message
  end

  protected

  def ensure_uuid
    self.uuid ||= UUID.generate
    self.save!
  end

  def target_directory
    File.join(uuid[0, 2], uuid[2, 2], uuid)
  end

  def target_file
    File.join(target_directory, File.basename(staging_path))
  end

  def ensure_directories

  end

end