class Workflow::AccrualJob < Workflow::Base
  belongs_to :cfs_directory, touch: true
  belongs_to :user, touch: true

  has_many :workflow_accrual_directories, :class_name => 'Workflow::AccrualDirectory', dependent: :destroy
  has_many :workflow_accrual_files, :class_name => 'Workflow::AccrualFile', dependent: :destroy

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

  STATES = %w(start copying amazon_backup mail end)

  def self.create_for(user, cfs_directory, staging_path)
    transaction do
      workflow = self.create!(cfs_directory: cfs_directory, user: user, staging_path: staging_path, state: 'start')
      workflow.create_accrual_requests
      workflow.put_in_queue
    end
  end

  def create_accrual_requests
    files, directories = staged_files_and_directories
    files.each do |file|
      workflow_accrual_files.create!(name: file.basename.to_s)
    end
    directories.each do |directory|
      workflow_accrual_directories.create!(name: directory.basename.to_s)
    end
  end

  def staged_files_and_directories
    staging_root, relative_path = staging_root_and_relative_path
    files = staging_root.files_at(relative_path)
    directories = staging_root.directories_at(relative_path)
    return files, directories
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
      cfs_directory.schedule_initial_assessments
      be_in_state_and_requeue('amazon_backup')
    end
  end

  def copy_entry(entry, source_path, target_path)
    Rsync.run(File.join(source_path, entry.name), target_path, '-a --ignore-existing') do |result|
      unless result.success?
        message = "Error doing rsync for accrual job #{self.id} for #{entry.class} #{entry.name}. Rescheduling."
        Rails.logger.error message
        raise RuntimeError, message
      end
    end
  end

  def perform_amazon_backup
    #TODO figure out how this should work, given that the Amazon Backup stuff currently will only expect to find a Workflow::Ingest
    #May have to add associated AmazonBackup to this, then it will check the various kinds of things that it might be
    #assigned to to see how to proceed instead of just Workflow::Ingest
    #For now, just skip to the next step
    be_in_state_and_requeue('mail')
  end

  def perform_mail
    Workflow::AccrualMailer.done(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_end
    true
  end

  def success(job)
    if self.state == 'end'
      self.destroy_queued_jobs_and_self
    end
  end

end
