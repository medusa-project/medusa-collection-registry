# app/services/accrual_validation/assessment_completion_validator.rb
# frozen_string_literal: true

require 'set'

module AccrualValidation
  class AssessmentCompletionValidator
    Result = Struct.new(
      :valid,
      :accrual_id,
      :cfs_directory_id,
      :checked_file_count,
      :missing_checksum_count,
      :missing_fits_count,
      :incomplete_assessor_task_count,
      :assessor_error_count,
      :pending_assessment_job_count,
      :missing_checksum_file_ids,
      :missing_fits_file_ids,
      :incomplete_assessor_task_ids,
      :assessor_error_task_ids,
      :pending_assessment_job_directory_ids,
      :blocking_failures,
      keyword_init: true
    )

    def initialize(accrual_job:)
      @accrual_job = accrual_job
    end

    def call
      blocking_failures = []

      if cfs_directory.blank?
        blocking_failures << 'Accrual job does not have a destination CFS directory.'

        return Result.new(
          valid: false,
          accrual_id: accrual_job.id,
          cfs_directory_id: nil,
          checked_file_count: 0,
          missing_checksum_count: 0,
          missing_fits_count: 0,
          incomplete_assessor_task_count: 0,
          assessor_error_count: 0,
          pending_assessment_job_count: 0,
          missing_checksum_file_ids: [],
          missing_fits_file_ids: [],
          incomplete_assessor_task_ids: [],
          assessor_error_task_ids: [],
          pending_assessment_job_directory_ids: [],
          blocking_failures: blocking_failures
        )
      end

      blocking_failures << 'One or more files are missing checksum values.' if missing_checksum_count.positive?
      blocking_failures << 'One or more files are missing FITS serialization.' if missing_fits_count.positive?
      blocking_failures << 'One or more assessor tasks are incomplete.' if incomplete_assessor_task_count.positive?
      blocking_failures << 'One or more assessor tasks have error responses.' if assessor_error_count.positive?
      blocking_failures << 'One or more directory assessment jobs are still pending.' if pending_assessment_job_count.positive?

      Result.new(
        valid: blocking_failures.empty?,
        accrual_id: accrual_job.id,
        cfs_directory_id: cfs_directory.id,
        checked_file_count: checked_file_count,
        missing_checksum_count: missing_checksum_count,
        missing_fits_count: missing_fits_count,
        incomplete_assessor_task_count: incomplete_assessor_task_count,
        assessor_error_count: assessor_error_count,
        pending_assessment_job_count: pending_assessment_job_count,
        missing_checksum_file_ids: missing_checksum_file_ids,
        missing_fits_file_ids: missing_fits_file_ids,
        incomplete_assessor_task_ids: incomplete_assessor_task_ids,
        assessor_error_task_ids: assessor_error_task_ids,
        pending_assessment_job_directory_ids: pending_assessment_job_directory_ids,
        blocking_failures: blocking_failures
      )
    end

    private

    attr_reader :accrual_job

    def cfs_directory
      @cfs_directory ||= accrual_job.cfs_directory
    end

    def files_in_tree
      @files_in_tree ||= cfs_directory.files_in_tree
    end

    def checked_file_count
      @checked_file_count ||= files_in_tree.count
    end

    # Existing Workflow::AccrualJob#has_pending_assessments? treats a nil md5_sum
    # as pending assessment work, so this validator uses that same completion rule.
    def files_missing_checksum
      @files_missing_checksum ||= files_in_tree.where(md5_sum: nil)
    end

    def missing_checksum_count
      @missing_checksum_count ||= files_missing_checksum.count
    end

    def missing_checksum_file_ids
      @missing_checksum_file_ids ||= files_missing_checksum.pluck(:id)
    end

    def files_missing_fits
      @files_missing_fits ||= files_in_tree.where(fits_serialized: false)
    end

    def missing_fits_count
      @missing_fits_count ||= files_missing_fits.count
    end

    def missing_fits_file_ids
      @missing_fits_file_ids ||= files_missing_fits.pluck(:id)
    end

    def assessor_task_elements
      @assessor_task_elements ||= cfs_directory.assessor_task_elements.to_a
    end

    def incomplete_assessor_tasks
      @incomplete_assessor_tasks ||= assessor_task_elements.select(&:incomplete?)
    end

    def incomplete_assessor_task_count
      @incomplete_assessor_task_count ||= incomplete_assessor_tasks.count
    end

    def incomplete_assessor_task_ids
      @incomplete_assessor_task_ids ||= incomplete_assessor_tasks.map(&:id)
    end

    def assessor_error_tasks
      @assessor_error_tasks ||= assessor_task_elements.select(&:has_errors?)
    end

    def assessor_error_count
      @assessor_error_count ||= assessor_error_tasks.count
    end

    def assessor_error_task_ids
      @assessor_error_task_ids ||= assessor_error_tasks.map(&:id)
    end

    # The existing accrual workflow uses has_pending_assessment_jobs?, which
    # returns true/false. This validator needs the actual pending directory IDs
    # for reporting, so it calculates the intersection directly.
    def pending_assessment_job_directory_ids
      @pending_assessment_job_directory_ids ||= begin
        subdirectory_ids = cfs_directory.recursive_subdirectory_ids.to_set

        possible_assessment_job_ids =
          Job::CfsInitialDirectoryAssessment
            .where(file_group_id: cfs_directory.file_group.id)
            .pluck(:cfs_directory_id)
            .to_set

        subdirectory_ids.intersection(possible_assessment_job_ids).to_a
      end
    end

    def pending_assessment_job_count
      @pending_assessment_job_count ||= pending_assessment_job_directory_ids.count
    end
  end
end