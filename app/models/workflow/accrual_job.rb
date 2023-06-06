# frozen_string_literal: true

# Note that there are (currently) two paths through copying - one where the CR does the copying itself,
# and one using a copy server. Configuration determines if the copy server can be used for a given ingest.
# One goes through the 'copying' state, the other through 'send_copy_messages' and 'await_copy_messages'
require 'set'

class Workflow::AccrualJob < Workflow::Base
  include ExcludedFiles

  attr_accessor :comment

  belongs_to :cfs_directory
  belongs_to :user

  has_many :workflow_accrual_directories, class_name: 'Workflow::AccrualDirectory', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_files, class_name: 'Workflow::AccrualFile', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_conflicts, class_name: 'Workflow::AccrualConflict', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_comments, -> { order 'created_at desc' }, class_name: 'Workflow::AccrualComment', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'
  has_many :workflow_accrual_keys, class_name: 'Workflow::AccrualKey', dependent: :delete_all, foreign_key: 'workflow_accrual_job_id'

  delegate :file_group, :root_cfs_directory, :collection, :repository, to: :cfs_directory

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

  STATE_HASH = {'start' => 'Start',
                'check' => 'Checking for existing files',
                'check_sync' => 'Checking sync',
                'initial_approval' => 'Awaiting approval',
                'copying' => 'Copying',
                'send_copy_messages' => 'Sending copying messages',
                'await_copy_messages' => 'Awaiting copy messages',
                'admin_approval' => 'Awaiting admin approval',
                'assessing' => 'Starting Assessments',
                'await_assessment' => 'Running Assessment',
                'email_done' => 'Emailing completion',
                'aborting' => 'Aborting',
                'end' => 'Ending'}.freeze
  STATES = STATE_HASH.keys

  def self.create_for(user, cfs_directory, staging_path, requested_files, requested_directories, allow_overwrite)
    transaction do
      workflow = create!(cfs_directory: cfs_directory, user: user, staging_path: staging_path, state: 'start', allow_overwrite: allow_overwrite)
      workflow.create_accrual_requests(requested_files, requested_directories)
      workflow.put_in_queue
    end
  end

  def self.awaiting_admin
    where(state: 'admin_approval')
  end

  def create_accrual_requests(requested_files, requested_directories)
    requested_files.each do |file|
      unless excluded_file?(file)
        Workflow::AccrualFile.create!(name: file, workflow_accrual_job: self)
      end
    end
    requested_directories.each do |directory|
      Workflow::AccrualDirectory.create!(name: directory, workflow_accrual_job: self)
    end
  end

  def staging_root_and_prefix
    # The form of staging_path is /root_name/pre/fix/. Note that splitting gives this blank entry
    # for the leading '/', but not the trailing one.
    path_components = staging_path.split('/').drop(1)
    # shift removes the first element of self and returns it https://apidock.com/ruby/Array/shift
    staging_root_name = path_components.shift
    staging_root = accrual_root(staging_root_name)
    prefix = path_components.join('/')
    [staging_root, prefix]
  end

  def staging_globus_endpoint
    # The form of staging_path is /root_name/pre/fix/. Note that splitting gives this blank entry
    # for the leading '/', but not the trailing one.
    path_components = staging_path.split('/').drop(1)
    # shift removes the first element of self and returns it https://apidock.com/ruby/Array/shift
    staging_root_name = path_components.shift
    StorageManager.instance.globus_endpoint_at(staging_root_name)
  end

  def accrual_root(name)
    StorageManager.instance.accrual_roots.at(name)
  end

  def perform_start
    be_in_state_and_requeue('check_sync')
  end

  # TODO: I'm going to assume for now that we are going to get rid of this step by having a
  # saner way to stage the content. If not we can revisit this stuff later. For now just
  # assume there is no sync and we're dealing directly with the staged content as the user
  # did it.
  def perform_check_sync
    be_in_state_and_requeue('check')
  end

  # TODO: See if we can't break this down a bit. It might do to have a class that does this work.
  # The files and directories should have been selected for existence in
  # submit method of AccrualsController
  # If there are duplicate files and overwrites are not allowed, quit and complain about it.
  # If there are empty files, mention it in passing.
  def ok_chars(input, pattern); result = input=~pattern; !result.nil? end
  def perform_check
    # safe_characters_regex = /\A[0-9a-zA-Z\/!.*'()-]*\z/
    # safe_chars_regex = /^[@ a-zA-Z\d&!_.*'(\/)-]+(\/[@ a-zA-Z\d&!_.*'()-]+)*$/
    # pattern = Regexp.new(safe_chars_regex).freeze
    root, prefix = staging_root_and_prefix
    ingest_keys = Set.new
    # unsafe_path_strings = Set.new
    empty_files = StringIO.new
    # Rails.logger.warn("#{Time.current} START adding workflow_accrual_files to ingest_keys")
    workflow_accrual_files.each do |file|
      key = file.name
      ingest_keys << key
      file.size = root.size(File.join(prefix, key))
      file.save!
      empty_files.puts(key) if file.size.zero?
      # unsafe_path_strings << key unless ok_chars(key, pattern)
    end
    # Rails.logger.warn("#{Time.current} END adding workflow_accrual_files to ingest_keys")
    # Rails.logger.warn("#{Time.current} START adding files within workflow_accrual_directories to ingest_keys.")
    workflow_accrual_directories.each do |directory|
      # get the keys in this directory relative to the accrual prefix
      directory_key = prefix.blank? ? directory.name : File.join(prefix, directory.name)
      keys = root.unprefixed_subtree_keys(directory_key).collect do |unprefixed_key|
        File.join(directory.name, unprefixed_key)
      end
      size = 0
      keys.each do |key|
        full_key = prefix.blank? ? key : File.join(prefix, key)
        key_size = root.size(full_key)
        size += key_size
        empty_files.puts(key) if key_size.zero?
        # unsafe_path_strings << full_key unless ok_chars(full_key, pattern)
      end
      directory.size = size
      directory.count = keys.count
      directory.save!
      ingest_keys += keys
    end
    # Rails.logger.warn("#{Time.current} END adding files within workflow_accrual_directories to ingest_keys.")
    update_attribute(:empty_file_report, empty_files.string)
    cfs_directory_prefix = cfs_directory.relative_path
    existing_keys = existing_keys_for(cfs_directory_prefix)
    duplicate_keys = ingest_keys.intersection(existing_keys)
    # TODO: we can implement other checks based on size and/or the beginning/end bytes of a file
    # to try to check for changes more efficiently before computing the entire md5.
    duplicate_keys.each do |key|
      # existing_md5 = StorageManager.instance.main_root.md5_sum(File.join(cfs_directory_prefix, key))
      #       # ingest_md5 = root.md5_sum(File.join(prefix, key))
      #       # file_changed = (existing_md5 != ingest_md5)
      file_changed = true
      workflow_accrual_conflicts.create!(path: key, different: file_changed)
    end
    if duplicate_keys.count.positive? && !allow_overwrite
      Workflow::AccrualMailer.illegal_overwrite(self).deliver_now
      be_in_state_and_requeue('end')
    # elsif unsafe_path_strings.count.positive?
    #   Workflow::AccrualMailer.unsafe_characters(self, unsafe_path_strings).deliver_now
    #   be_in_state_and_requeue('end')
    else
      create_workflow_accrual_keys(ingest_keys)
      be_in_state('initial_approval')
      Workflow::AccrualMailer.initial_approval(self).deliver_now
    end
  end

  def existing_keys_for(prefix)
    StorageManager.instance.main_root.unprefixed_subtree_keys(prefix)
  rescue MedusaStorage::Error::InvalidDirectory => e
    # getting here means directory does not exist, which is expected for new accruals
    []
  end

  def create_workflow_accrual_keys(keys)
    workflow_accrual_keys.clear
    keys.each do |key|
      unless excluded_file?(File.basename(key))
        workflow_accrual_keys.create(key: key)
      end
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
    target_root = StorageManager.instance.main_root
    #TODO - this could run through Parallel if advisable -
    # however, with the try below I get database connection issues
    # could not obtain a connection from the pool withing 5.000 seconds ...
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

  def use_globus_transfer

    return false if Rails.env.development? || Rails.env.test?

    return false unless Settings.globus.present?

    !staging_globus_endpoint.nil?
  end

  def perform_send_copy_messages
    reset_conflict_fixities_and_fits if has_serious_conflicts?
    source_endpoint = staging_globus_endpoint
    target_endpoint = StorageManager.instance.globus_endpoint_at('main_storage')
    target_prefix = cfs_directory.relative_path
    workflow_accrual_keys.copy_not_requested.find_each do |workflow_accrual_key|

      if workflow_accrual_key.exists_on_main_root?
        workflow_accrual_key.update_attribute(:copy_requested, true)
      else
        source_key = File.join(workflow_accrual_key.key).gsub(%r{^/}, '')
        target_key = File.join(workflow_accrual_key.key)
        source_path = File.join(staging_path, source_key)
        destination_path = File.join(target_endpoint[:path].gsub(%r{^/}, ''), target_prefix, target_key)
        destination_path = "/#{destination_path}" unless destination_path[0] == "/"


        Workflow::GlobusTransfer.create(workflow_accrual_key_id: workflow_accrual_key.id,
                                                       source_uuid: source_endpoint[:uuid],
                                                       destination_uuid: target_endpoint[:uuid],
                                                       source_path: source_path,
                                                       destination_path: destination_path,
                                                       recursive: false)

      end
    end
    be_in_state_and_requeue('await_copy_messages')
  end

  # checks the status of all globus transfers for all accrual keys for this accrual job
  def perform_await_copy_messages
    workflow_accrual_keys.where(copy_requested: true).where(error: nil).each do |workflow_accrual_key|
      case workflow_accrual_key.workflow_globus_transfer.state
      when 'SUCCEEDED'
        workflow_accrual_key.destroy!
      when 'ACTIVE'
        #do nothing
      when 'INACTIVE', 'FAILED'
        workflow_accrual_key.copy_requested = false
        message = "#{status}: https://www.globus.org/app/console/#{workflow_accrual_key.workflow_globus_transfer.task_link}"
        workflow_accrual_key.error = message
        workflow_accrual_key.save!
        #when 'CONFLICT'
        #workflow_accrual_key.error = "conflict error getting status"
        #workflow_accrual_key.save!
        #when 'ERROR'
        #workflow_accrual_key.copy_requested = false
        #workflow_accrual_key.error = "error getting status"
        #workflow_accrual_key.save!
      else
        # do nothing
        #workflow_accrual_key.copy_requested = false
        #workflow_accrual_key.error = "error getting status"
        #workflow_accrual_key.save!
        #raise("Invalid status in perform_await_copy_messages for workflow_accrual_key: #{workflow_accrual_key}")
      end
    end
    error_count = workflow_accrual_keys.has_error.count
    unless error_count.zero?
      raise "There are #{error_count} keys with copying errors."
    end
    if workflow_accrual_keys.reload.count.zero?
      cfs_directory.events.create!(key: 'deposit_completed', cascadable: true,
                                   note: "Accrual from #{staging_path}", actor_email: user.email)
      be_in_state_and_requeue('assessing')
    else
      put_in_queue(run_at: 30.minutes.from_now)
    end

  end

  # At this time this is meant for calling in a console if we get some failures that need to be retried. This might be automated
  # as well, i.e. just automatically try this one or two times if we get into a bad state.
  def retry_failed_copies
    delayed_jobs.each(&:destroy!)
    workflow_accrual_keys.where('error is not null').each do |key|
      key.workflow_globus_transfer.cancel
      key.copy_requested = false
      key.error = nil
      key.save!
    end
    be_in_state_and_requeue('send_copy_messages')
  end

  def reset_conflict_fixities_and_fits
    workflow_accrual_conflicts.where(different: true).find_each(&:reset_cfs_file)
  end

  def perform_aborting
    Workflow::AccrualMailer.aborted(self).deliver_now
    archive('aborted')
    be_in_state_and_requeue('end')
  end

  # TODO: - this could maybe target the content of the ingest more precisely and thus be more
  # efficient. As is it may run over a lot of stuff that is already there unnecessarily.
  # Maybe just assess any workflow_accrual_files keys directly and do the workflow_accrual_directory keys by making the
  # directories if they don't exist and then assessing them.
  def perform_assessing

    raise("Directory assessment jobs pending, duplicate attempt to assess.") if has_pending_assessment_jobs?

    assessor_task_elements_exist = cfs_directory.assessor_task_elements.count.positive?
    raise("Assessor::TaskElements already created, duplicate attempt assess.") if assessor_task_elements_exist

    cfs_directory.make_and_assess_tree
    update_attribute(:assessment_start_time, Time.current)
    update_attribute(:assessment_attempt_count, 1)
    # sleep to give make_and_assess_tree process time to create records for has_pending_assessments? to detect
    sleep(30)
    be_in_state_and_requeue('await_assessment')
  end

  def retry_stale_assessments

    Assessor::Response.where(status: "processing").where("updated_at >= created_at + interval '1' hour").each(&:handle)

    begin
      response = Assessor::Response.fetch_message
      while response != nil
        response = Assessor::Response.fetch_message
      end
      fetched_responses = Assessor::Response.where(status: "fetched").limit(100)
      while fetched_responses.count.positive?
        fetched_responses.each(&:handle)
        fetched_responses = Assessor::Response.where(status: "fetched").limit(100)
      end
      destroy_complete_assessments
      if has_pending_assessments?
        update_attribute(:assessment_start_time, Time.now.utc)
        update_attribute(:assessment_attempt_count, assessment_attempt_count + 1)
        cfs_directory.retry_stale_assessments if Assessor::Task.current_tasks.count.zero?
        put_in_queue(run_at: 30.minutes.from_now)
      else
        Workflow::AccrualMailer.assessment_done(self).deliver_now
        be_in_state_and_requeue('email_done')
      end
    rescue StandardError => ex
      Rails.logger.warn "Error retrying assessment for Workflow::AccrualJob #{self.id}: #{ex.class}"
      Rails.logger.warn ex.message
      update_attribute(:assessment_attempt_count, assessment_attempt_count + 1)
      put_in_queue(run_at: 30.minutes.from_now)
    end

  end

  def perform_await_assessment
    destroy_complete_assessments
    if has_pending_assessments?
      if assessment_attempt_count > Settings.classes.workflow.accrual_job.assessment_attempt_count_max
        raise "Assessments are still pending. Accrual Job: #{id}. Cfs Directory: #{cfs_directory.id}"
      else
        retry_stale_assessments
      end
    else
      Workflow::AccrualMailer.assessment_done(self).deliver_now
      be_in_state_and_requeue('email_done')
    end
  end

  def destroy_complete_assessments
    cfs_directory.destroy_complete_assessments
  end

  def has_assessment_errors?
    cfs_directory.assessor_task_elements do |element|
      return true if element.has_errors?
    end

    false
  end
  # Are there any initial directory assessments belonging to a subdirectory of this accrual jobs cfs directory?
  def has_pending_assessments?
    cfs_directory.each_file_in_tree do |file|
      next if file.nil?

      return true if file.md5_sum.nil?

      return true if file.fits_serialized == false

      return true if file.has_incomplete_assessor_task?
    end

    has_pending_assessment_jobs?
  end
  def files_missing_checksum
    missing = []
    cfs_directory.each_file_in_tree do |file|
      next if file.nil?
      missing << file if file.md5_sum.nil?
    end
    missing
  end

  def files_missing_fits
    missing = []
    cfs_directory.each_file_in_tree do |file|
      next if file.nil?
      missing << file if file.fits_serialized == false
    end
    missing
  end
  def incomplete_assessor_tasks
    destroy_complete_assessments
    cfs_directory.assessor_task_elements
  end
  def has_pending_assessment_jobs?
    transaction do
      subdirectory_ids = cfs_directory.recursive_subdirectory_ids.to_set
      possible_assessment_job_ids = Job::CfsInitialDirectoryAssessment.where(file_group_id: cfs_directory.file_group.id).pluck(:cfs_directory_id).to_set
      return subdirectory_ids.intersect?(possible_assessment_job_ids)
    end
  end
  def pending_assessment_jobs
      subdirectory_ids = cfs_directory.recursive_subdirectory_ids.to_set
      possible_assessment_job_ids = Job::CfsInitialDirectoryAssessment.where(file_group_id: cfs_directory.file_group.id).pluck(:cfs_directory_id).to_set
      subdirectory_ids.intersect(possible_assessment_job_ids)
  end
  def perform_email_done
    Workflow::AccrualMailer.done(self).deliver_now
    archive('completed')
    be_in_state_and_requeue('end')
    # TODO: - perhaps delete staged content, perhaps not
  end

  def status_label
    STATE_HASH[state]
  end

  def approve_and_proceed
    case state
    when 'initial_approval'
      be_in_state('admin_approval')
      notify_admin_of_request
    when 'admin_approval'
      update_attribute(:copy_start_time, Time.now.utc)
      if use_globus_transfer
        be_in_state_and_requeue('send_copy_messages')
      else
        be_in_state_and_requeue('copying')
      end
    else
      raise "Job approved from unallowed initial state : #{state}"
    end
  end

  def archive(completion_state)
    ArchivedAccrualJob.create!(workflow_accrual_job_id: id, file_group_id: file_group.id, cfs_directory_id: cfs_directory_id,
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
    !state.in?(%w[start check])
  end

  def delayed_job_has_error?
    return false unless delayed_jobs.count.positive?

    delayed_jobs.each do |job|
      return true unless job.last_error.nil?
    end
    return false
  end

  def delayed_job_status
    return "JOB OK" unless delayed_job_has_error?

    delayed_jobs.each do |job|
      last_error =  job.last_error
      break unless last_error.nil?
    end

    return "JOB DELAY-RETRYING" if last_error.downcase.include("conflict")

  end

  def file_group
    cfs_directory.file_group
  end

  def file_group_title
    file_group.try(:title)
  rescue StandardError
    '[UNKNOWN]'
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

  def total_accrual_key_count
    Workflow::AccrualKey.where(workflow_accrual_job_id: self.id).count
  end

  def size
    workflow_accrual_directories.sum(:size) + workflow_accrual_files.sum(:size)
  end

  class RenderingController < ActionController::Renderer
    attr_accessor :workflow_accrual
  end

  def render_report
    rendered_html = ApplicationController.render(
      partial: 'workflow/accrual_mailer/view_report',
      assigns: {
        workflow_accrual: self
      }
    )
    rendered_html
  end

  def status_detail
    report_array = Array.new
    report_array << "Status: #{status_label}"
    case state
    when "start"
      report_array << "The only thing that happens in #{status_label} is moving onto the checking sync state."
      report_array << "Status should not remain #{status_label} for more than a few minutes."
    when "check_sync"
      report_array << "The only thing that happens in #{status_label} is moving into the checking for existing files states."
      report_array << "Status should not remain #{status_label} for more than a few minutes."
    when "check"
      report_array << "The directories and files in the staged content are compared to the objects already ingested."
      report_array << "If duplicates are found and the overwrites are specified as not allowed in the ingest then a"
      report_array << "report is sent to the initiator of the ingest and the Workflow::AccrualJob goes to the end state."
      report_array << " If overwrites are allowed, the check is still done and the results reported."
      report_array << "If no duplicates are found or overwrite is allowed, then Workflow::WorkflowAccrualKey objects"
      report_array << "are created for all of the staged content files, an approval prompt email is sent, and the"
      report_array << "Workflow::AccrualJob changes state to awaiting approval."
    when "initial_approval"
      report_array << "A Proceed or Abort option is offered in the dashboard. If Proceed is clicked by"
      report_array << "an authorized user, a message is sent to the associated administrator and the state is changed"
      report_array << "to awaiting admin approval."
    when "copying"
      report_array << "Files are copied using different methods for object stores, such as AWS S3 buckets"
      report_array << "vs. filesystems, but generally requires a fast, reliable connection to the staging and"
      report_array << "medusa storage systems. When copying is finished, the state is changed to starting assessments."
    when "send_copy_messages"
      report_array << "A Globus transfer request records is made for each individual file."
      report_array << "After all transfer records are sent, the state is changed to await copy messages."
    when  "await_copy_messages"
      report_array << "Globus transfer requests are sent asynchronously by a background job."
      report_array << "Each Workflow::AccrualKey's Globus transfer request status is checked."
      report_array << "Checking the transfer status first checks if the object has been copied."
      report_array << "If it has been copied, the Workflow::AccrualKey record is destroyed."
      report_array << "If there is a reported error, that error is recorded."
      report_array << "If there is no error, but the object has not yet been copied yet,"
      report_array << "then nothing happens during that check."
      report_array << "Checking status happens in a loop until all of the transfers succeed or have a reported error."
      report_array << " Currently, errors need to be cleared up manually by developer."
      report_array << "After all files are confirmed copied, the state changes to starting assessments."
    when "admin_approval"
      report_array << "A Proceed or Abort option is offered in the dashboard. If Proceed is clicked by "
      report_array << "an authorized user, the state is changed to sending copying messages."
    when "assessing"
      report_array << "The cfs_directory (see File Organization) specified in the ingest request is prompted"
      report_array << "to initiate two parallel asynchronous background tasks: one to examine the storage tree"
      report_array << "associated with that cfs_directory and make the Medusa records match what exists in storage,"
      report_array << "and the other to send calls to the Medusa Assessor Service to get results of checksum"
      report_array << "calculation, media type detection, and fits processing for any files that don't already"
      report_array << "have those done, which is expected to be exactly the newly ingested objects."
      report_array << "Once those tasks have been initiated, the state changes to running assessment."
    when "await_assessment"
      report_array << "Each of the processes initiated while in assessing status are checked continuously over and over"
      report_array << "until they are all complete. After all are complete, the state changes to emailing completion."
    when "email_done"
      report_array << "The done email is sent and the state changes to ending."
      report_array << "Status should not remain #{status_label} for more than a few minutes."
    when "aborting"
      report_array << "A Workflow::AccrualJob in this state sends an aborted message and then the state changes to end"
      report_array << "Status should not remain #{status_label} for more than a few minutes."
    when "end"
      report_array << "Destroys the accrual job record and any associated background job records."
      report_array << "Status should not remain #{status_label} for more than a few minutes."
    else
      report_array << "Invalid status: #{state}"
    end
  end

  def globus_transfers
    Workflow::GlobusTransfer.where(workflow_accrual_key_id: workflow_accrual_keys.pluck(:id))
  end

  def globus_transfers_unsent
    globus_transfers.where(state: nil)
  end

  def globus_transfers_with_error
    globus_transfers.where(state: 'ERROR')
  end

  def globus_transfers_active
    globus_transfers.where(state: 'ACTIVE')
  end

  def diagnostic_info
    report_array = Array.new
    report_array << "*** DIAGNOSTIC TIPS ***"
    case state
    when "start", "check_sync", "email_done", "aborting", "end"
      report_array << "Shares a queue with the background job that checks for existing files."
      report_array << "If job is stuck here, background jobs may not not running."
      report_array << "Rebooting the server may necessary and sufficient."
      report_array << "If this happens shortly after a reboot, check logs for exception reports."
      report_array << "An exception in a Delayed::Job might be making Delayed:Job objects fail."
    when "check"
      report_array << "The last step in this state is to create the Workflow::AccrualKey record for non-excluded files."
      report_array << "A lot is done in memory without creating records."
      report_array << "This can take a long time without interim results to monitor for large ingests."
    when  "copying"
      report_array << "#{self.workflow_accrual_keys.count} total files"
      report_array << "#{self.workflow_accrual_keys.where(copy_requested: true).where(error: nil).count} files left to copy"
      report_array << "#{self.workflow_accrual_keys.where(copy_requested: true).where.not(error: nil).count} requests have errors"
      report_array << "If the number of files left to copy is not zero, but keeps going down on successive "
      report_array << "refreshes on the scale of minutes, then this step is progressing normally."
    when "send_copy_messages"
      report_array <<  "This step just creates the Workflow::GlobusTransfer record."
      report_array << "The call to Globus is made asynchronously via background job in the Awaiting copy messages stage."
      report_array << "This stage should usually not last more than 15 minutes."
    when  "await_copy_messages"
      report_array << "#{self.workflow_accrual_keys.where(copy_requested: true).count} Globus Transfer requested"
      report_array << "#{self.workflow_accrual_keys.where(copy_requested: false).count} Globus Transfers to be requested"
      report_array << "For a total of #{self.workflow_accrual_keys.count} objects left to copy"
      "#{self.workflow_accrual_keys.where.not(error: nil).count} objects have errors"
    when "admin_approval"
      report_array <<  "not yet implemented"
    when "assessing"
      report_array << "All subdirectory records are created before any file records are created."
      report_array << "(subdirectories: #{self.cfs_directory.recursive_subdirectory_ids.count} records created)\n"
      report_array << "(files: #{self.cfs_directory.recursive_cfs_file_ids.count} records created)"
    when "await_assessment"
      report_array << "All subdirectory records are created before any file records are created."
      report_array << "(subdirectories: #{self.cfs_directory.recursive_subdirectory_ids.count} records created)\n"
      report_array << "(files: #{self.cfs_directory.recursive_cfs_file_ids.count} records created)"
      report_array << "Assessments are checked every 30 minutes up to 100 times. Attempts so far: #{assessment_attempt_count}"
    else
      report_array << "Invalid state: #{state}"
    end
    report_array << "*** BACKGROUND JOBS ****"
    report_array << "Number of associated background jobs: #{self.delayed_jobs.count}"
    error_jobs = self.delayed_jobs.reject {|dj| dj.last_error.nil?}
    report_array << "Number of associated background jobs with errors: #{error_jobs.count}"
    report_array
  end
end
