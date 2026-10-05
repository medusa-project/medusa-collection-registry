# app/services/accrual_validation/completion_validation_error.rb
# frozen_string_literal: true

# Raised when final accrual validation fails.
#
# This marks the Delayed Job run as failed after the workflow has sent the
# validation failure email and moved the accrual into the final_validation_failed
# state.

module AccrualValidation
  class CompletionValidationError < StandardError
    attr_reader :validation_result

    def initialize(accrual_job:, validation_result:)
      @validation_result = validation_result
      super("Final accrual validation failed for Workflow::AccrualJob #{accrual_job.id}")
    end
  end
end