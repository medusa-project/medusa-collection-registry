#Note that there are (currently) two paths through copying - one where the CR does the copying itself,
# and one using a copy server. Configuration determines if the copy server can be used for a given ingest.
# One goes through the 'copying' state, the other through 'send_copy_messages' and 'await_copy_messages'
require 'render_anywhere'
require 'set'

class Workflow::AccrualJob < Workflow::Base
  include RenderAnywhere
  include ExcludedFiles

  attr_accessor :comment

  belongs_to :cfs_directory
  belongs_to :user

  has_many :workflow_accrual_directories, class_name: 'Workflow::AccrualDirectory', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_files, class_name: 'Workflow::AccrualFile', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_conflicts, class_name: 'Workflow::AccrualConflict', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_comments, -> {order 'created_at desc'}, class_name: 'Workflow::AccrualComment', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_keys, :class_name => 'Workflow::AccrualKey', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'

  delegate :file_group, :root_cfs_directory, :collection, :repository, to: :cfs_directory

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

  STATE_HASH = {'start' => 'Start', 'check' => 'Checking for existing files', 'check_sync' => 'Checking sync',
                'initial_approval' => 'Awaiting approval',
                'copying' => 'Copying',
                'send_copy_messages' => 'Sending copying messages', 'await_copy_messages' => 'Awaiting copy messages',
                'admin_approval' => 'Awaiting admin approval',
                'assessing' => 'Starting Assessments', 'await_assessment' => 'Running Assessment',
                'email_done' => 'Emailing completion',
                'aborting' => 'Aborting', 'end' => 'Ending'}
  STATES = STATE_HASH.keys

  def self.create_for(user, cfs_directory, staging_path, requested_files, requested_directories, allow_overwrite)
    transaction do
      workflow = self.create!(cfs_directory: cfs_directory, user: user, staging_path: staging_path, state: 'start', allow_overwrite: allow_overwrite)
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

  def staging_root_and_prefix
    #The form of staging_path is /root_name/pre/fix/. Note that splitting gives this blank entry
    # for the leading '/', but not the trailing one.
    path_components = staging_path.split('/').drop(1)
    staging_root_name = path_components.shift
    staging_root = accrual_root(staging_root_name)
    prefix = path_components.join('/')
    return staging_root, prefix
  end

  def accrual_root(name)
    Application.storage_manager.accrual_roots.at(name)
  end

  def perform_start
    be_in_state_and_requeue('check_sync')
  end

  #TODO: I'm going to assume for now that we are going to get rid of this step by having a
  # saner way to stage the content. If not we can revisit this stuff later. For now just
  # assume there is no sync and we're dealing directly with the staged content as the user
  # did it.
  def perform_check_sync
    be_in_state_and_requeue('check')
  end

  #TODO See if we can't break this down a bit. It might do to have a class that does this work.
  def perform_check
    root, prefix = staging_root_and_prefix
    ingest_keys = Set.new
    empty_files = StringIO.new
    workflow_accrual_files.each do |file|
      key = file.name
      ingest_keys << key
      file.size = root.size(File.join(prefix, key))
      file.save!
      empty_files.puts(key) if file.size.zero?
    end
    workflow_accrual_directories.each do |directory|
      #get the keys in this directory relative to the accrual prefix
      directory_key = prefix.blank? ? directory.name : File.join(prefix, directory.name)
      keys = root.unprefixed_subtree_keys(directory_key).collect do |unprefixed_key|
        File.join(directory.name, unprefixed_key)
      end
      size = 0
      keys.each do |key|
        key_size = root.size(File.join(prefix, key))
        size += key_size
        empty_files.puts(key) if key_size.zero?
      end
      directory.size = size
      directory.count = keys.count
      directory.save!
      ingest_keys += keys
    end
    update_attribute(:empty_file_report, empty_files.string)
    cfs_directory_prefix = cfs_directory.relative_path
    existing_keys = existing_keys_for(cfs_directory_prefix)
    duplicate_keys = ingest_keys.intersection(existing_keys)
    duplicate_keys.each do |key|
      existing_md5 = Application.storage_manager.main_root.md5_sum(File.join(cfs_directory_prefix, key))
      ingest_md5 = root.md5_sum(File.join(prefix, key))
      file_changed = (existing_md5 != ingest_md5)
      workflow_accrual_conflicts.create!(path: key, different: file_changed)
    end
    if has_serious_conflicts? and (not allow_overwrite)
      Workflow::AccrualMailer.illegal_overwrite(self).deliver_now
      be_in_state_and_requeue('end')
    else
      create_workflow_accrual_keys(ingest_keys)
      be_in_state('initial_approval')
      Workflow::AccrualMailer.initial_approval(self).deliver_now
    end
  end

  def existing_keys_for(prefix)
    Application.storage_manager.main_root.unprefixed_subtree_keys(prefix)
  rescue MedusaStorage::Error::InvalidDirectory
    Array.new
  end

  def create_workflow_accrual_keys(keys)
    workflow_accrual_keys.clear
    keys.each do |key|
      workflow_accrual_keys.create(key: key) unless excluded_file?(File.basename(key))
    end
  end

  def perform_initial_approval
    unrunnable_state
  end

  def perform_admin_approval
    unrunnable_state
  end

  def internal_perform_copying(overwrite: false)
    source_root, source_prefix = staging_root_and_prefix
    target_prefix = cfs_directory.relative_path
    target_root = Application.storage_manager.main_root
    #TODO - this could run through Parallel if advisable -
    # however, with the try below I get database connection issues
    # could not obtain a connectino from the pool withing 5.000 seconds ...
    # all pooled connections were in use
    # So I'm going to revert for now
    # workflow_accrual_keys.find_each do |key|
    #   source_key = File.join(source_prefix, key.key)
    #   target_key = File.join(target_prefix, key.key)
    #   if overwrite or !target_root.exist?(target_key)
    #     target_root.copy_content_to(target_key, source_root, source_key)
    #   end
    #   key.destroy!
    # end
    workflow_accrual_keys.find_in_batches(batch_size: Settings.classes.workflow.accrual_job.copying_batch_size) do |key_batch|
      Parallel.each(key_batch, in_threads: Settings.classes.workflow.accrual_job.copying_parallel_threads) do |key|
        source_key = File.join(source_prefix, key.key)
        target_key = File.join(target_prefix, key.key)
        if overwrite or !target_root.exist?(target_key)
          target_root.copy_content_to(target_key, source_root, source_key)
        end
        key.destroy!
      end
    end
    if workflow_accrual_keys.reload.count.zero?
      be_in_state_and_requeue('assessing')
    else
      raise "Unexpected workflow accrual keys still exist."
    end
  end

  def perform_copying
    if has_serious_conflicts?
      internal_perform_copying(overwrite: true)
      reset_conflict_fixities_and_fits
    else
      internal_perform_copying(overwrite: false)
    end
    cfs_directory.events.create!(key: 'deposit_completed', cascadable: true,
                                 note: "Accrual from #{staging_path}", actor_email: user.email)
  end

  def use_copy_server
    #TODO - use the configuration available to decide what to do
    # If we have a configuration section for a copy server and the appropriate roots are covered, then
    # use it.
    return false unless Settings.copy_server.present?
    staging_root, prefix = staging_root_and_prefix
    staging_root_name = staging_root.name
    target_root_name = Application.storage_manager.main_root.name
    return (Settings.copy_server.roots.include?(staging_root_name) && Settings.copy_server.roots.include?(target_root_name))
  end

  def perform_send_copy_messages
    amqp = AmqpHelper::Connector[:medusa]
    staging_root, source_prefix = staging_root_and_prefix
    staging_root_name = staging_root.name
    target_prefix = cfs_directory.relative_path
    target_root_name = Application.storage_manager.main_root.name
    workflow_accrual_keys.copy_not_requested.find_each do |workflow_accrual_key|
      source_key = File.join(source_prefix, workflow_accrual_key.key).gsub(/^\//, '')
      target_key = File.join(target_prefix, workflow_accrual_key.key)
      amqp.send_message(Settings.copy_server.outgoing_queue,
                        copy_message(staging_root_name, source_key, target_root_name, target_key, workflow_accrual_key))
      workflow_accrual_key.copy_requested = true
      workflow_accrual_key.save!
    end
    be_in_state_and_requeue('await_copy_messages') if workflow_accrual_keys.copy_not_requested.count.zero?
  end

  def copy_message(source_root_name, source_key, target_root_name, target_key, workflow_accrual_key)
    {
        action: 'copyto',
        pass_through: {
            workflow_accrual_key_id: workflow_accrual_key.id
        },
        parameters: {
            source_root: source_root_name,
            target_root: target_root_name,
            source_key: source_key,
            target_key: target_key
        }
    }
  end

  #Note that the way this works when this is run by _any_ job using the copying server, it will (potentially)
  # pick up and deal with the messages for _any_ jobs that have incoming messages. This is fine, as the check
  # on whether to proceed is just to check if this job has no more messages remaining. So if the current job
  # processes messages for another job's copy, it just means that that part got a head start - the other job
  # will still make the necessary check when _its_ delayed job is run, it just will have received a head start
  # on processing the messages.
  def perform_await_copy_messages
    #TODO - pick up any incoming messages and remove the associated accrual keys or report errors
    # Mark errors directly on the workflow_accrual_key, and then after getting all of the incoming
    # messages check for errors and report once if there are any present.
    amqp = AmqpHelper::Connector[:medusa]
    continue_processing = true
    while continue_processing
      amqp.with_parsed_message(Settings.copy_server.incoming_queue) do |message|
        if message
          workflow_accrual_key = Workflow::AccrualKey.find(message['pass_through']['workflow_accrual_key_id'])
          if message['status'] == 'success'
            workflow_accrual_key.destroy!
          else
            workflow_accrual_key.error = message['message']
            workflow_accrual_key.save!
          end
        else
          continue_processing = false
        end
      end
    end
    error_count = workflow_accrual_keys.has_error.count
    unless error_count.zero?
      raise "There are #{error_count} keys with copying errors."
    end
    if workflow_accrual_keys.reload.count.zero?
      be_in_state_and_requeue('assessing')
    else
      if self.created_at + Settings.classes.workflow.accrual_job.copy_server_error_reporting_timeout > Time.now
        self.put_in_queue(run_at: Time.now + Settings.classes.workflow.accrual_job.copy_server_requeue_interval)
      else
        raise RuntimeError, "Copy server jobs are still pending. Accrual Job: #{self.id}. Cfs Directory: #{self.cfs_directory.id}"
      end
    end
  end

  def reset_conflict_fixities_and_fits
    workflow_accrual_conflicts.where(different: true).find_each {|conflict| conflict.reset_cfs_file}
  end

  def perform_aborting
    Workflow::AccrualMailer.aborted(self).deliver_now
    archive('aborted')
    be_in_state_and_requeue('end')
  end

  def perform_assessing
    cfs_directory.make_and_assess_tree
    be_in_state_and_requeue('await_assessment')
  end

  def perform_await_assessment
    if has_pending_assessments?
      if self.created_at + Settings.classes.workflow.accrual_job.assessment_error_reporting_timeout > Time.now
        self.put_in_queue(run_at: Time.now + Settings.classes.workflow.accrual_job.assessment_requeue_interval)
      else
        raise RuntimeError, "Assessments are still pending. Accrual Job: #{self.id}. Cfs Directory: #{self.cfs_directory.id}"
      end
    else
      Workflow::AccrualMailer.assessment_done(self).deliver_now
      be_in_state_and_requeue('email_done')
    end
  end

  #Are there any initial directory assessments belonging to a subdirectory of this accrual jobs cfs directory?
  def has_pending_assessments?
    transaction do
      subdirectory_ids = self.cfs_directory.recursive_subdirectory_ids.to_set
      possible_assessment_job_ids = Job::CfsInitialDirectoryAssessment.where(file_group_id: self.cfs_directory.file_group.id).pluck(:cfs_directory_id).to_set
      return subdirectory_ids.intersect?(possible_assessment_job_ids)
    end
  end

  def perform_email_done
    Workflow::AccrualMailer.done(self).deliver_now
    archive('completed')
    be_in_state_and_requeue('end')
    #TODO - perhaps delete staged content, perhaps not
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
      if use_copy_server
        be_in_state_and_requeue('send_copy_messages')
      else
        be_in_state_and_requeue('copying')
      end
    else
      raise RuntimeError, 'Job approved from unallowed initial state'
    end
  end

  def archive(completion_state)
    ArchivedAccrualJob.create!(workflow_accrual_job_id: self.id, file_group_id: file_group.id, cfs_directory_id: cfs_directory_id,
                               user_id: user_id, state: completion_state, staging_path: staging_path, report: render_report)
  end

  def abort_and_proceed
    be_in_state_and_requeue('aborting')
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
    set_instance_variable('workflow_accrual', self)
    render partial: 'workflow/accrual_mailer/view_report'
  end

end
