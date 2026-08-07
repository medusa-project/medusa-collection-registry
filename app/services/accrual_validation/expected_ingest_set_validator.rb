# app/services/accrual_validation/expected_ingest_set_validator.rb

# frozen_string_literal: true

require "set"

module AccrualValidation
  class ExpectedIngestSetValidator
    Result = Struct.new(
      :valid,
      :accrual_id,
      :expected_file_count,
      :actual_file_count,
      :missing_files,
      :missing_directories,
      :directory_count_mismatches,
      :blocking_failures,
      keyword_init: true
    )

    def initialize(accrual_job:)
      @accrual_job = accrual_job
    end

    def call
      missing_files = expected_top_level_file_names - actual_top_level_file_names.to_a
      missing_directories = expected_directory_names - actual_expected_directory_names.to_a
      directory_count_mismatches = build_directory_count_mismatches

      expected_file_count = accrual_job.total_file_count
      actual_file_count = actual_top_level_file_names.size + actual_directory_file_counts.values.sum

      blocking_failures = []

      if expected_file_count != actual_file_count
        blocking_failures << "Expected ingest file count does not match actual ingested file count."
      end

      if missing_files.any?
        blocking_failures << "One or more expected top-level files are missing from the ingested result."
      end

      if missing_directories.any?
        blocking_failures << "One or more expected accrual directories are missing from the ingested result."
      end

      if directory_count_mismatches.any?
        blocking_failures << "One or more expected accrual directories have an incorrect ingested file count."
      end

      Result.new(
        valid: blocking_failures.empty?,
        accrual_id: accrual_job.id,
        expected_file_count: expected_file_count,
        actual_file_count: actual_file_count,
        missing_files: missing_files,
        missing_directories: missing_directories,
        directory_count_mismatches: directory_count_mismatches,
        blocking_failures: blocking_failures
      )
    end

    private

    attr_reader :accrual_job

    def destination_root
      accrual_job.cfs_directory
    end

    def destination_prefix
      @destination_prefix ||= destination_root.relative_path
    end

    def expected_top_level_file_names
      @expected_top_level_file_names ||= accrual_job.workflow_accrual_files.pluck(:name)
    end

    def expected_top_level_file_name_set
      @expected_top_level_file_name_set ||= expected_top_level_file_names.to_set
    end

    def expected_directories
      @expected_directories ||= accrual_job.workflow_accrual_directories.pluck(:name, :count)
    end

    def expected_directory_names
      @expected_directory_names ||= expected_directories.map(&:first)
    end

    def expected_directory_name_set
      @expected_directory_name_set ||= expected_directory_names.to_set
    end

    def expected_directory_counts
      @expected_directory_counts ||= expected_directories.to_h
    end

    def expected_directory_paths_by_name
      @expected_directory_paths_by_name ||= expected_directory_names.index_with do |directory_name|
        File.join(destination_prefix, directory_name)
      end
    end

    def expected_directory_paths
      @expected_directory_paths ||= expected_directory_paths_by_name.values
    end

    def actual_top_level_file_names
      @actual_top_level_file_names ||= begin
        return Set.new if expected_top_level_file_name_set.empty?

        CfsFile.where(
          cfs_directory_id: destination_root.id,
          name: expected_top_level_file_name_set.to_a
        ).pluck(:name).to_set
      end
    end

    def actual_expected_directory_names
      @actual_expected_directory_names ||= actual_expected_directories_by_name.keys.to_set
    end

    def actual_directory_file_counts
      @actual_directory_file_counts ||= begin
        counts = expected_directory_names.index_with { 0 }

        actual_expected_directories_by_name.each do |directory_name, directory|
          counts[directory_name] = directory.files_in_tree.count
        end

        counts
      end
    end

    def actual_expected_directories_by_name
      @actual_expected_directories_by_name ||= begin
        return {} if expected_directory_name_set.empty?

        expected_directory_names.each_with_object({}) do |directory_name, directories|
          directory = find_expected_directory(directory_name)
          directories[directory_name] = directory if directory
        end
      end
    end

    #Find the expected directory as a direct CFS child of the destination root,
    #using the local directory name.
    def find_expected_directory(directory_name)
      direct_child_directories_by_path[directory_name] ||
        root_directories_by_full_path[File.join(destination_prefix, directory_name)]
    end

    def direct_child_directories_by_path
      @direct_child_directories_by_path ||= begin
        CfsDirectory.where(
          parent_id: destination_root.id,
          parent_type: "CfsDirectory",
          path: expected_directory_names
        ).index_by(&:path)
      end
    end

    def root_directories_by_full_path
      @root_directories_by_full_path ||= begin
        CfsDirectory.where(
          root_cfs_directory_id: destination_root.id,
          path: expected_directory_paths
        ).index_by(&:path)
      end
    end

    def build_directory_count_mismatches
      expected_directory_counts.each_with_object([]) do |(directory_name, expected_count), mismatches|
        actual_count = actual_directory_file_counts.fetch(directory_name, 0)

        next if actual_count == expected_count

        mismatches << {
          directory: directory_name,
          expected: expected_count,
          actual: actual_count
        }
      end
    end
  end
end