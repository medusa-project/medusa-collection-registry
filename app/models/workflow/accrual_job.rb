require 'find'

class Workflow::AccrualJob < Workflow::Base
  belongs_to :cfs_directory, touch: true
  belongs_to :user, touch: true
  belongs_to :amazon_backup, touch: true

  has_many :workflow_accrual_directories, class_name: 'Workflow::AccrualDirectory', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_files, class_name: 'Workflow::AccrualFile', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_conflicts, class_name: 'Workflow::AccrualConflict', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

  STATE_HASH = {'start' => 'Start', 'check' => 'Checking for existing files',
                'initial_approval' => 'Awaiting approval',
                'copying' => 'Copying', 'copying_with_overwrite' => 'Copying with overwrite',
                'overwrite_approval' => 'Awaiting admin approval', 'amazon_backup' => 'Amazon backup',
                'aborting' => 'Aborting', 'end' => 'Ending'}
  STATES = STATE_HASH.keys

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
    source_path = staging_source_path
    existing_files = Set.new.tap do |existing_files|
      Dir.chdir(cfs_directory.absolute_path) do
        Find.find('.') do |entry|
          existing_files << entry.sub(/\.\//, '') if File.file?(entry)
        end
      end
    end
    requested_files = Set.new.tap do |requested_files|
      self.workflow_accrual_files.each { |file| requested_files << file.name }
      Dir.chdir(source_path) do
        self.workflow_accrual_directories.each do |directory|
          Find.find(directory.name) do |entry|
            requested_files << entry if File.file?(entry)
          end
        end
      end
    end
    duplicate_files = existing_files.intersection(requested_files)
    duplicate_files.each do |duplicate_file|
      file_changed = file_changed?(duplicate_file, source_path)
      workflow_accrual_conflicts.create!(path: duplicate_file, different: file_changed)
    end
    self.state = 'initial_approval'
    self.save!
    Workflow::AccrualMailer.initial_approval(self).deliver_now
  end

  def file_changed?(file, source_path)
    old_md5 = cfs_directory.find_file_at_relative_path(file).md5_sum
    new_md5 = Digest::MD5.file(File.join(source_path, file)).to_s
    old_md5 != new_md5
  end

  def perform_intial_approval
    unrunnable_state
  end

  def perform_overwrite_approval
    unrunnable_state
  end

  def perform_copying
    source_path = staging_source_path
    target_path = cfs_directory.absolute_path
    workflow_accrual_files.each do |file|
      copy_entry(file, source_path, target_path, overwrite: false)
      file.destroy!
    end
    workflow_accrual_directories.each do |directory|
      copy_entry(directory, source_path, target_path, overwrite: false)
      directory.destroy!
    end
    transaction do
      cfs_directory.make_initial_tree
      cfs_directory.schedule_initial_assessments
      be_in_state_and_requeue('amazon_backup')
    end
  end

  def perform_copying_with_overwrite
    source_path = staging_source_path
    target_path = cfs_directory.absolute_path
    workflow_accrual_files.each do |file|
      copy_entry(file, source_path, target_path, overwrite: true)
      file.destroy!
    end
    workflow_accrual_directories.each do |directory|
      copy_entry(directory, source_path, target_path, overwrite: true)
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

  def copy_entry(entry, source_path, target_path, overwrite: false)
    opts = overwrite ? '-a --ignore-times' : '-a --ignore-times --ignore-existing'
    source_entry = File.join(source_path, entry.name)
    return unless File.exists?(source_entry)
    Rsync.run(source_entry, target_path, opts) do |result|
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

  def perform_aborting
    self.destroy_queued_jobs_and_self
    Workflow::AccrualMailer.aborted(self).deliver_now
  end

  def perform_end
    Workflow::AccrualMailer.done(self).deliver_now
    #TODO - perhaps delete staged content, perhaps not
  end

  def success(job)
    if self.state.in('end', 'aborting')
      self.destroy_queued_jobs_and_self
    end
  end

  def file_group
    self.cfs_directory.file_group
  end

  def collection
    self.file_group.collection
  end

  def status_label
    STATE_HASH[self.state]
  end

  def approve_and_proceed
    case state
      when 'initial_approval'
        if self.workflow_accrual_conflicts.serious.count > 0
          self.state = 'overwrite_approval'
          self.save!
        else
          be_in_state_and_requeue('copying')
        end
      when 'overwrite_approval'
        be_in_state_and_requeue('copying_with_overwrite')
      else
        raise RuntimeError, 'Job approved from unallowed initial state'
    end
  end

  def abort_and_proceed
    be_in_state_and_requeue('aborting')
  end

end
