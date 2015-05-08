# Create (in start state) and enqueue
# - change to copying state, copy directory, reenqueue
# - change to backing up state, register amazon backup, do not reenqueue
# - when backup is complete, it will call back to finish process and delete

require 'fileutils'

class Workflow::Ingest < Workflow::Base
  belongs_to :external_file_group, touch: true
  belongs_to :bit_level_file_group, touch: true
  belongs_to :user, touch: true
  belongs_to :amazon_backup, touch: true

  validates_uniqueness_of :external_file_group_id, allow_blank: false

  STATES = %w(start copying amazon_backup end)

  def self.create_for(user, external_file_group, bit_level_file_group)
    transaction do
      workflow = self.create!(user: user, external_file_group: external_file_group,
                              bit_level_file_group: bit_level_file_group, state: 'start')
      workflow.put_in_queue
    end
  end

  def runnable?
    unless external_file_group.present? and bit_level_file_group.present?
      raise RuntimeError, "File group missing for Workflow::Ingest: #{id}"
    end
    super
  end

  def perform_start
    be_in_state_and_requeue('copying')
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
    self.transaction do
      cfs_directory = CfsDirectory.find_or_create_by!(path: self.bit_level_file_group.expected_relative_cfs_root_directory)
      cfs_directory.parent = bit_level_file_group
      cfs_directory.save!
      collection = self.bit_level_file_group.collection
      collection.preservation_priority = PreservationPriority.find_by(name: 'ingested')
      collection.save!
      be_in_state_and_requeue('amazon_backup')
    end
  end

  def perform_amazon_backup
    self.transaction do
      unless AmazonBackup.find_by(user_id: self.user.id, cfs_directory_id: self.bit_level_file_group.cfs_directory.id, date: Date.today)
        self.amazon_backup = AmazonBackup.create!(user_id: self.user.id, cfs_directory_id: self.bit_level_file_group.cfs_directory.id,
                                                  date: Date.today)
        self.save!
        Job::AmazonBackup.create_for(self.amazon_backup)
        #stay in amazon backup state - AmazonBackup will take care of next transition when the glacier server sends the
        #return message
      end
    end
  end

  def perform_end
    Workflow::IngestMailer.done(self).deliver_now
    Job::IngestStagingDelete.create_for(self.external_file_group, self.user)
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
