require 'find'
require 'open3'
require 'render_anywhere'

class Workflow::AccrualJob < Workflow::Base
  include RenderAnywhere

  attr_accessor :comment

  belongs_to :cfs_directory
  belongs_to :user
  belongs_to :amazon_backup

  has_many :workflow_accrual_directories, class_name: 'Workflow::AccrualDirectory', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_files, class_name: 'Workflow::AccrualFile', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_conflicts, class_name: 'Workflow::AccrualConflict', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_comments, -> { order 'created_at desc' }, class_name: 'Workflow::AccrualComment', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'

  delegate :file_group, :root_cfs_directory, :collection, :repository, to: :cfs_directory

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

  STATE_HASH = {'start' => 'Start', 'check' => 'Checking for existing files', 'check_sync' => 'Checking sync',
                'initial_approval' => 'Awaiting approval',
                'copying' => 'Copying', 'admin_approval' => 'Awaiting admin approval',
                'amazon_backup' => 'Amazon backup', 'amazon_backup_completed' => 'Amazon backup completed',
                'email_done' => "Emailing completion",
                'aborting' => 'Aborting', 'end' => 'Ending'}
  STATES = STATE_HASH.keys

  def self.create_for(user, cfs_directory, staging_path, requested_files, requested_directories)
    transaction do
      workflow = self.create!(cfs_directory: cfs_directory, user: user, staging_path: staging_path, state: 'start')
      workflow.create_accrual_requests(requested_files, requested_directories)
      workflow.put_in_queue
    end
  end

  def self.awaiting_admin
    where(state: 'admin_approval')
  end

  def create_accrual_requests(requested_files, requested_directories)
    requested_files.each do |file|
      Workflow::AccrualFile.create!(name: file, workflow_accrual_job: self) unless excluded_file?(file)
    end
    requested_directories.each do |directory|
      Workflow::AccrualDirectory.create!(name: directory, workflow_accrual_job: self)
    end
  end

  def staging_root_and_relative_path
    path_components = staging_path.split('/').drop(1)
    staging_root_name = path_components.shift
    relative_path = path_components.join('/')
    staging_root = AccrualStorage.instance.root_named(staging_root_name)
    return staging_root, relative_path
  end

  def perform_start
    be_in_state_and_requeue('check_sync')
  end

  def perform_check_sync
    comparator = DirectoryTreeComparator.new(staging_remote_path, staging_local_path)
    if comparator.directories_equal?
      be_in_state_and_requeue('check')
    else
      raise RuntimeError,
            %Q(storage.library and condo copies of accrual directory are not in sync.
#{comparator.source_only_paths.count} files are only present in the source copy
#{comparator.target_only_paths.count} files are only present in the target copy
#{comparator.different_sizes_paths.count} files are present in both copies but with different sizes)
    end
  end

  def perform_check
    add_stats
    source_path = staging_local_path
    duplicate_files(source_path).each do |duplicate_file|
      file_changed = file_changed?(duplicate_file, source_path)
      workflow_accrual_conflicts.create!(path: duplicate_file, different: file_changed)
    end
    be_in_state('initial_approval')
    Workflow::AccrualMailer.initial_approval(self).deliver_now
  end

  def add_stats
    source_path = staging_local_path
    workflow_accrual_files.each do |file|
      file.size = File.size(File.join(source_path, file.name))
      file.save!
    end
    workflow_accrual_directories.each do |directory|
      Dir.chdir(File.join(source_path, directory.name)) do
        count = 0
        size = 0
        Find.find('.') do |entry|
          count += 1
          size += File.size(entry)
        end
        directory.count = count
        directory.size = size
        directory.save!
      end
    end
  end

  def duplicate_files(source_path)
    existing_files.intersection(requested_files(source_path))
  end

  def requested_files(source_path)
    Set.new.tap do |files|
      self.workflow_accrual_files.each { |file| files << file.name }
      Dir.chdir(source_path) do
        self.workflow_accrual_directories.each do |directory|
          Find.find(directory.name) do |entry|
            files << entry if File.file?(entry)
          end
        end
      end
    end
  end

  def existing_files
    Set.new.tap do |files|
      Dir.chdir(cfs_directory.absolute_path) do
        Find.find('.') do |entry|
          files << entry.sub(/\.\//, '') if File.file?(entry)
        end
      end
    end
  end

  def file_changed?(file, source_path)
    #if the initial assessment hasn't been done yet this can error out, i.e. if the db and file system views of the
    #existing content are different
    old_md5 = cfs_directory.find_file_at_relative_path(file).md5_sum
    new_md5 = Digest::MD5.file(File.join(source_path, file)).to_s
    old_md5 != new_md5
  end

  def perform_initial_approval
    unrunnable_state
  end

  def perform_admin_approval
    unrunnable_state
  end

  def internal_perform_copying(overwrite: false)
    source_path = staging_local_path
    target_path = cfs_directory.absolute_path
    copy_entries_and_remove(workflow_accrual_files, source_path, target_path, overwrite: overwrite)
    copy_entries_and_remove(workflow_accrual_directories, source_path, target_path, overwrite: overwrite)
    cfs_directory.make_and_assess_tree
    be_in_state_and_requeue('amazon_backup')
  end

  def perform_copying
    if has_serious_conflicts?
      internal_perform_copying(overwrite: true)
    else
      internal_perform_copying(overwrite: false)
    end
    cfs_directory.events.create!(key: 'deposit_completed', cascadable: true,
                                 note: "Accrual from #{staging_path}", actor_email: user.email)
  end

  def staging_local_path
    staging_root, relative_path = staging_root_and_relative_path
    staging_root.full_local_path_to(relative_path)
  end

  def staging_remote_path
    staging_root, relative_path = staging_root_and_relative_path
    staging_root.full_remote_path_to(relative_path)
  end

  #note that this means remove the db model from the accrual job, not the files from the source filesystem
  def copy_entries_and_remove(entries, source_path, target_path, overwrite: false)
    entries.each do |entry|
      copy_entry(entry, source_path, target_path, overwrite: overwrite)
      entry.destroy!
    end
  end

  def copy_entry(entry, source_path, target_path, overwrite: false)
    opts = %w(-a --ignore-times --chmod Dug+w --exclude-from) << exclude_file_path
    opts << '--ignore-existing' unless overwrite
    source_entry = File.join(source_path, entry.name)
    return unless File.exists?(source_entry)
    out, err, status = Open3.capture3('rsync', *opts, source_entry, target_path)
    unless status.success?
      message = <<MESSAGE
Error doing rsync for accrual job #{self.id} for #{entry.class} #{entry.name}.
STDOUT: #{out}
STDERR: #{err}
Rescheduling.
MESSAGE
      Rails.logger.error message
      raise RuntimeError, message
    end
  end

  def exclude_file_path
    File.join(Rails.root, 'config', 'accrual_rsync_exclude.txt')
  end

  def excluded_file?(file)
    %w(Thumbs.db .DS_Store).include?(file)
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
    #TODO this return doesn't get us out of this state - may need to do
    #something else instead. If the file group isn't present what does that
    #mean?
    return if file_group.blank?
    today = Date.today
    transaction do
      if future_backup = AmazonBackup.find_by(cfs_directory_id: root_cfs_directory.id, date: today + 1)
        assign_amazon_backup(future_backup, run_backup: false)
      elsif AmazonBackup.find_by(cfs_directory_id: root_cfs_directory.id, date: today)
        assign_amazon_backup(AmazonBackup.create!(user_id: self.user.id, cfs_directory_id: root_cfs_directory.id, date: today + 1),
                             run_backup: true, backup_options: {run_at: today + 1.day + 1.hour})
      else
        assign_amazon_backup(AmazonBackup.create!(user_id: self.user.id, cfs_directory_id: root_cfs_directory.id, date: today),
                             run_backup: true)
      end
    end
    #Stay in amazon_backup state - Amazon Backup will do the transition when it receives a reply from the glacier server
  end

  def assign_amazon_backup(backup, run_backup: false, backup_options: {})
    self.amazon_backup = backup
    self.save!
    Job::AmazonBackup.create_for(backup, backup_options) if run_backup
  end

  def perform_aborting
    Workflow::AccrualMailer.aborted(self).deliver_now
    archive('aborted')
    be_in_state_and_requeue('end')
  end

  def perform_amazon_backup_completed
    be_in_state_and_requeue('email_done')
  end

  def perform_email_done
    Workflow::AccrualMailer.done(self).deliver_now
    archive('completed')
    be_in_state_and_requeue('end')
    #TODO - perhaps delete staged content, perhaps not
  end

  def has_outstanding_assessments?
    Job::CfsInitialDirectoryAssessment.where(file_group_id: self.file_group.id).present? or
        Job::CfsInitialFileGroupAssessment.where(file_group_id: self.file_group.id).present?
  end

  def status_label
    STATE_HASH[self.state]
  end

  def approve_and_proceed
    case state
      when 'initial_approval'
        be_in_state('admin_approval')
        notify_admin_of_request
      when 'admin_approval'
        be_in_state_and_requeue('copying')
      else
        raise RuntimeError, 'Job approved from unallowed initial state'
    end
  end

  def archive(completion_state)
    ArchivedAccrualJob.create!(workflow_accrual_job_id: self.id, file_group_id: file_group.id, cfs_directory_id: cfs_directory_id,
    amazon_backup_id: amazon_backup_id, user_id: user_id, state: completion_state, staging_path: staging_path, report: render_report)
  end

  def abort_and_proceed
    be_in_state_and_requeue('aborting')
  end

  def has_conflicts?
    workflow_accrual_conflicts.count > 0
  end

  def has_serious_conflicts?
    workflow_accrual_conflicts.serious.count > 0
  end

  def notify_admin_of_request
    Workflow::AccrualMailer.notify_admin_of_incoming_request(self).deliver_now
  end

  def has_report?
    !self.state.in?(%w(start check))
  end

  def file_group
    cfs_directory.file_group
  end

  def file_group_title
    file_group.try(:title) rescue '[UNKNOWN]'
  end

  def relative_target_path
    cfs_directory.relative_path
  end

  def directory_count
    workflow_accrual_directories.count
  end

  def top_level_file_count
    workflow_accrual_files.count
  end

  def total_file_count
    top_level_file_count + workflow_accrual_directories.sum(:count)
  end

  def size
    workflow_accrual_directories.sum(:size) + workflow_accrual_files.sum(:size)
  end

  class RenderingController < RenderAnywhere::RenderingController
    attr_accessor :workflow_accrual
  end

  def render_report
    set_instance_variable("workflow_accrual", self)
    render partial: 'workflow/accrual_mailer/view_report'
  end

end
