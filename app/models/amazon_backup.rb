class AmazonBackup < ApplicationRecord
  include AmazonBackupAmqp

  serialize :archive_ids
  before_create :initialize_archive_ids_and_date

  belongs_to :cfs_directory
  #This is the user who requested the backup, needed so we can email progress reports
  belongs_to :user

  has_one :job_amazon_backup, class_name: 'Job::AmazonBackup', dependent: :destroy
  has_many :workflow_accrual_jobs, :class_name => 'Workflow::AccrualJob'
  has_many :workflow_project_item_ingests, :class_name => 'Workflow::ProjectItemIngest'

  #Only allow one backup per day for a file group
  validates_uniqueness_of :date, scope: :cfs_directory_id

  validates_presence_of :user_id, :date

  def self.descending_date
    order('date desc')
  end

  def self.preceding(date)
    where('date < ?', date)
  end

  def initialize_archive_ids_and_date
    self.archive_ids ||= Array.new
    self.date ||= Date.today
  end

  #Return the previous backup for the file group, or nil
  def previous_backup
    self.cfs_directory.amazon_backups.preceding(self.date).descending_date.first
  end

  def request_backup
    self.part_count = 1
    self.archive_ids = [nil]
    self.save!
    self.send_backup_request_message
  end

  def glacier_description
    file_group = self.cfs_directory.file_group
    description = %Q(Amazon Backup Id: #{self.id}
Date: #{self.date}
Cfs Directory Id: #{self.cfs_directory.id}
Cfs Directory: #{self.cfs_directory.key}
    )
    if file_group
      description << %Q(File Group Id: #{file_group.id}
Collection Id: #{file_group.collection.id}
Repository Id: #{file_group.repository.id}
      )
    end
    return description
  end

  def create_backup_completion_event
    file_group = self.cfs_directory.file_group
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

  def self.create_and_schedule(user, cfs_directory)
    backup = self.create!(user_id: user.id, cfs_directory_id: cfs_directory.id, date: Date.today)
    Job::AmazonBackup.create_for(backup)
  end

end