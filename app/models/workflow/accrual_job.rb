require 'find'

class Workflow::AccrualJob < Workflow::Base
  belongs_to :cfs_directory, touch: true
  belongs_to :user, touch: true
  belongs_to :amazon_backup, touch: true

  has_many :workflow_accrual_directories, class_name: 'Workflow::AccrualDirectory', dependent: :destroy, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_files, class_name: 'Workflow::AccrualFile', dependent: :destroy, foreign_key: 'workflow_accrual_job_id'

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

  STATES = %w(start check copying amazon_backup end)

  def self.create_for(user, cfs_directory, staging_path, requested_files, requested_directories)
    transaction do
      workflow = self.create!(cfs_directory: cfs_directory, user: user, staging_path: staging_path, state: 'start')
      workflow.create_accrual_requests(requested_files, requested_directories)
      workflow.put_in_queue
    end
  end

  def create_accrual_requests(requested_files, requested_directories)
    requested_files.each do |file|
      Workflow::AccrualFile.create!(name: file, workflow_accrual_job: self)
    end
    requested_directories.each do |directory|
      Workflow::AccrualDirectory.create!(name: directory, workflow_accrual_job: self)
    end
  end

  def staging_root_and_relative_path
    path_components = staging_path.split('/').drop(1)
    staging_root_name = path_components.shift
    relative_path = path_components.join('/')
    staging_root = StagingStorage.instance.root_named(staging_root_name)
    return staging_root, relative_path
  end

  def perform_start
    be_in_state_and_requeue('check')
  end

  def perform_check
    existing_files = Set.new.tap do |existing_files|
      Dir.chdir(cfs_directory.absolute_path) do
        x = cfs_directory.absolute_path
        Find.find('.') do |entry|
          existing_files << entry.sub(/\.\//, '') if File.file?(entry)
        end
      end
    end
    requested_files = Set.new.tap do |requested_files|
      self.workflow_accrual_files.each {|file| requested_files << file.name}
      Dir.chdir(staging_source_path) do
        self.workflow_accrual_directories.each do |directory|
          Find.find(directory.name) do |entry|
            requested_files << entry if File.file?(entry)
          end
        end
      end
    end
    duplicate_files = existing_files.intersection(requested_files)
    if duplicate_files.empty?
      be_in_state_and_requeue('copying')
    else
      Workflow::AccrualMailer.duplicates(self, duplicate_files).deliver_now
      destroy_queued_jobs_and_self
    end
  end

  def perform_copying
    source_path = staging_source_path
    target_path = cfs_directory.absolute_path
    workflow_accrual_files.each do |file|
      target_file = File.join(target_path, file.name)
      copy_entry(file, source_path, target_path) unless File.exists?(target_file)
      file.destroy!
    end
    workflow_accrual_directories.each do |directory|
      copy_entry(directory, source_path, target_path)
      directory.destroy!
    end
    transaction do
      cfs_directory.make_initial_tree
      cfs_directory.schedule_initial_assessments
      be_in_state_and_requeue('amazon_backup')
    end
  end

  def staging_source_path
    staging_root, relative_path = staging_root_and_relative_path
    staging_root.full_local_path_to(relative_path)
  end

  def copy_entry(entry, source_path, target_path)
    source_entry = File.join(source_path, entry.name)
    return unless File.exists?(source_entry)
    Rsync.run(source_entry, target_path, '-a --ignore-existing') do |result|
      unless result.success?
        message = "Error doing rsync for accrual job #{self.id} for #{entry.class} #{entry.name}. Rescheduling."
        Rails.logger.error message
        raise RuntimeError, message
      end
    end
  end

  #We have to be a little careful here, as we want to make sure the backup happens, but at the same time it may
  #be the case that there is already a backup scheduled or ongoing, and in light of the fact that we only allow a single
  #backup per file group / date pair we may need to latch on to an existing backup or schedule a backup in the future.
  #How we proceed: If there is already a backup scheduled for after today then make that the amazon backup for this, but
  #don't create another job to run it. If not and there is a job scheduled for today then make a job for tomorrow and
  #run it. If not then make a job for today and run it. Let errors propagate.
  #In addition to this we need to make the association to AmazonBackup one to many and the message receiving method
  #must reflect that.
  def perform_amazon_backup
    file_group = cfs_directory.file_group
    return if file_group.blank?
    root_cfs_directory = file_group.cfs_directory
    today = Date.today
    future_backup = AmazonBackup.find_by(cfs_directory_id: root_cfs_directory.id, date: today + 1)
    current_backup = AmazonBackup.find_by(cfs_directory_id: root_cfs_directory.id, date: today)
    transaction do
      if future_backup
        self.amazon_backup = future_backup
        self.save!
      elsif current_backup
        self.amazon_backup = AmazonBackup.create!(user_id: self.user.id, cfs_directory_id: root_cfs_directory.id, date: today + 1)
        self.save!
        Job::AmazonBackup.create_for(self.amazon_backup, run_at: today + 1.day + 1.hour)
      else
        self.amazon_backup = AmazonBackup.create!(user_id: self.user.id, cfs_directory_id: root_cfs_directory.id, date: today)
        self.save!
        Job::AmazonBackup.create_for(self.amazon_backup)
      end
    end
    #Stay in amazon_backup state - Amazon Backup will do the transition when it receives a reply from the glacier server
  end

  def perform_end
    Workflow::AccrualMailer.done(self).deliver_now
    #TODO - perhaps delete staged content, perhaps not
  end

  def success(job)
    if self.state == 'end'
      self.destroy_queued_jobs_and_self
    end
  end

end
