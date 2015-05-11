class Workflow::AccrualJob < Workflow::Base
  belongs_to :cfs_directory, touch: true
  belongs_to :user, touch: true
  belongs_to :amazon_backup, touch: true

  has_many :workflow_accrual_directories, class_name: 'Workflow::AccrualDirectory', dependent: :destroy, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_files, class_name: 'Workflow::AccrualFile', dependent: :destroy, foreign_key: 'workflow_accrual_job_id'

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

  STATES = %w(start copying amazon_backup end)

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
    be_in_state_and_requeue('copying')
  end

  def perform_copying
    staging_root, relative_path = staging_root_and_relative_path
    source_path = staging_root.full_local_path_to(relative_path)
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

  def perform_amazon_backup
    file_group = cfs_directory.file_group
    return if file_group.blank?
    root_cfs_directory = file_group.cfs_directory
    transaction do
      unless AmazonBackup.find_by(user_id: self.user.id, cfs_directory_id: root_cfs_directory.id, date: Date.today)
        self.amazon_backup = AmazonBackup.create!(user_id: self.user.id, cfs_directory_id: root_cfs_directory.id, date: Date.today)
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
