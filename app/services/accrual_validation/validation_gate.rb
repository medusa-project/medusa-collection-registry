# app/services/accrual_validation/validation_gate.rb
# frozen_string_literal: true

# run accrual validators sequentially
# exit on error or validator returning false with blocking failures

module AccrualValidation
  class ValidationGate
    Result = Struct.new(
      :valid,
      :validator_name,
      :validator_result,
      :error,
      keyword_init: true
    ) do
      def blocking_failures
        if error
          ['An unexpected error occurred while running the final accrual validation.']
        elsif validator_result
          validator_result.blocking_failures
        else
          []
        end
      end
    end

    VALIDATORS = [
      ['DestinationStorageValidator', AccrualValidation::DestinationStorageValidator],
      ['ExpectedIngestSetValidator', AccrualValidation::ExpectedIngestSetValidator],
      ['AssessmentCompletionValidator', AccrualValidation::AssessmentCompletionValidator]
    ].freeze

    def initialize(accrual_job)
      @accrual_job = accrual_job
    end

    def call
      VALIDATORS.each do |validator_name, validator_class|
        validation_result = run_validator(validator_class)

        unless validation_result.valid
          return Result.new(
            valid: false,
            validator_name: validator_name,
            validator_result: validation_result,
            error: nil
          )
        end
      rescue StandardError => e
        return Result.new(
          valid: false,
          validator_name: validator_name,
          validator_result: nil,
          error: e
        )
      end

      Result.new(
        valid: true,
        validator_name: nil,
        validator_result: nil,
        error: nil
      )
    end

    private

    attr_reader :accrual_job

    def run_validator(validator_class)
      validator_class.new(accrual_job: accrual_job).call
    end
  end
end