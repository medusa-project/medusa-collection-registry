#Create bags to be sent to Amazon Glacier for backup (other code will be
# responsible for requesting creation and for actually uploading)
#Receive the (bit level) file group to back up
#Figure out if there are previous backups and use this information
#to restrict files to back up.
#Make a list of files to back up
#If necessary break the list into pieces for size considerations
#Make bag(s) as backup - use bagit gem
# - create bag b = BagIt::Bag.new(path)
# - add files b.add_file(dest_path, source_path)
# - make manifests b.manifest!
#Extract manifest files from created bags and store

#Record backup in AmazonBackup (relate to filegroup, hold manifest file names, date)

#Config
# - backup registry directory (stores manifests)
# - bag creation dir - where to create the bags - this will
# need significant space, so probably will need to be on our main storage
# - maximum size of bag (environment sensitive so as to enable testing)

#Registry/bag naming format: fg<id>-<dt>-p<part>[.txt|.zip]
require 'fileutils'
class AmazonBackup < ActiveRecord::Base

  serialize :archive_ids
  before_create :initialize_archive_ids_and_date

  belongs_to :cfs_directory
  has_one :job_amazon_backup, :class_name => 'Job::AmazonBackup', :dependent => :destroy
  #This is the user who requested the backup, needed so we can email progress reports
  belongs_to :user
  has_one :workflow_ingest, :class_name => 'Workflow::Ingest'

  #Only allow one backup per day for a file group
  validates_uniqueness_of :date, scope: :cfs_directory_id

  validates_presence_of :user_id, :date

  def initialize_archive_ids_and_date
    self.archive_ids ||= Array.new
    self.date ||= Date.today
  end

  #Return the previous backup for the file group, or nil
  def previous_backup
    self.cfs_directory.amazon_backups.where('date < ?', self.date).order('date desc').first
  end

  def request_backup
    self.part_count = 1
    self.archive_ids = [nil]
    self.save!
    self.send_backup_request_message
  end

  def send_backup_request_message
    date = self.previous_backup.try(:date)
    request = {action: 'upload_directory',
               parameters: {directory: self.cfs_directory.path, description: self.glacier_description, date: date},
               pass_through: {backup_job_class: self.class.to_s, backup_job_id: self.id, directory: self.cfs_directory.path}}
    AmqpConnector.instance.send_message(self.class.outgoing_queue, request)
  end

  def glacier_description
    file_group = self.cfs_directory.file_group
    description = %Q(Amazon Backup Id: #{self.id}
Date: #{self.date}
Cfs Directory Id: #{self.cfs_directory.id}
Cfs Directory: #{self.cfs_directory.absolute_path}
    )
    if file_group
      description << %Q(File Group Id: #{file_group.id}
Collection Id: #{file_group.collection.id}
Repository Id: #{file_group.repository.id}
      )
    end
    return description
  end

  def on_amazon_backup_succeeded_message(response)
    self.archive_ids = response.archive_ids
    self.part_count = self.archive_ids.length
    self.save!
    AmazonMailer.progress(self).deliver
    create_backup_completion_event
    if self.completed?
      self.job_amazon_backup.try(:destroy)
      self.workflow_ingest.try(:be_at_end)
    end
  end

  def on_amazon_backup_failed_message(response)
    AmazonMailer.failure(self, response.error_message).deliver
  end

  def on_amazon_backup_unrecognized_message(response)
    AmazonMailer.failure.deliver(self, 'Unrecognized status code in AMQP response')
  end

  def create_backup_completion_event
    file_group = self.cfs_directory.try(:file_group)
    if file_group
      event = Event.new(eventable: file_group, date: Date.today, actor_email: self.user.email)
      event.key = 'amazon_backup_completed'
      event.note = "Glacier backup completed. #{self.part_count} part(s) backed up."
      event.save!
    end
  end

  def completed_part_count
    self.archive_ids.count { |x| x.present? }
  end

  def completed?
    self.part_count.present? and self.archive_ids.present? and (self.completed_part_count == self.part_count)
  end

  def self.storage_root
    MedusaRails3::Application.medusa_config['amazon']['bag_storage_root']
  end

  def self.incoming_queue
    MedusaRails3::Application.medusa_config['amazon']['incoming_queue']
  end

  def self.outgoing_queue
    MedusaRails3::Application.medusa_config['amazon']['outgoing_queue']
  end

end