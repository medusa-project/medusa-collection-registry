# Create (in start state) and enqueue
# - change to copying state, copy directory, reenqueue
# - change to backing up state, register amazon backup, do not reenqueue
# - when backup is complete, it will call back to finish process and delete

require 'fileutils'

class Workflow::Ingest < Job::Base
  belongs_to :external_file_group
  belongs_to :bit_level_file_group
  belongs_to :user
  belongs_to :amazon_backup

  STATES = %w(start copying amazon_backup end)

  def self.create_for(user, external_file_group, bit_level_file_group)
    workflow = self.create!(user: user, external_file_group: external_file_group,
                            bit_level_file_group: bit_level_file_group, state: 'start')
    workflow.put_in_queue
  end

  def put_in_queue
    Delayed::Job.enqueue(self, priority: 30)
  end

  def perform
    self.send("perform_#{self.state}")
  end

  def perform_start
    self.state = 'copying'
    self.save!
    self.put_in_queue
  end

  def perform_copying
    FileUtils.mkdir_p(self.bit_level_file_group.expected_absolute_cfs_root_directory)
    #copy files from staged location to cfs storage
    Rsync.run(self.external_file_group.local_staged_file_location + '/', self.bit_level_file_group.expected_absolute_cfs_root_directory,
              '-a') do |result|
      unless result.success?
        message = "Error doing rsync for ingest job #{self.id}. Rescheduling"
        Rails.logger.error message
        raise RuntimeError, message
      end
    end
    cfs_directory = CfsDirectory.find_or_create_by(path: self.bit_level_file_group.expected_relative_cfs_root_directory)
    bit_level_file_group.cfs_directory = cfs_directory
    bit_level_file_group.save!
    self.state = 'amazon_backup'
    self.save!
    self.put_in_queue
  end

  def perform_amazon_backup
    self.amazon_backup = AmazonBackup.create(user_id: self.user.id, cfs_directory_id: self.bit_level_file_group.cfs_directory.id,
                                             date: Date.today)
    self.save!
    Job::AmazonBackup.create_for(self.amazon_backup)
    #stay in amazon backup state - AmazonBackup will take care of next transition when the glacier server sends the
    #return message
  end

  def perform_end
    Workflow::IngestMailer.done(self).deliver
    Job::IngestStagingDelete.create_for(self.external_file_group, self.user)
  end

  def be_at_end
    self.state = 'end'
    self.save!
    self.put_in_queue
  end

  def success(job)
    if self.state == 'end'
      self.destroy_queued_jobs_and_self
    end
  end

  def most_advanced_file_group
    self.bit_level_file_group || self.external_file_group
  end

end
