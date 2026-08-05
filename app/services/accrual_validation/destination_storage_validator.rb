# frozen_string_literal: true

require "set"

module AccrualValidation
  class DestinationStorageValidator

    Result = Struct.new(
      :valid,
      :accrual_id,
      :destination_prefix,
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

      if destination_root.blank?
        blocking_failures << "Accrual job does not have a destination CFS directory."
      end

      if destination_prefix.blank?
        blocking_failures << "Accrual destination does not have a valid relative path."
      end

      if expected_file_count != actual_file_count
        blocking_failures << "Expected storage file count does not match actual destination storage file count."
      end

      if missing_files.any?
        blocking_failures << "One or more expected top-level files are missing from destination storage."
      end

      if missing_directories.any?
        blocking_failures << "One or more expected accrual directories are missing from destination storage."
      end

      if directory_count_mismatches.any?
        blocking_failures << "One or more expected accrual directories have an incorrect destination storage file count."
      end

      Result.new(
        valid: blocking_failures.empty?,
        accrual_id: accrual_job.id,
        destination_prefix: destination_prefix,
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
      @destination_prefix ||= destination_root&.relative_path
    end

    def storage_root
      @storage_root ||= StorageManager.instance.main_root
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

    def expected_top_level_file_paths_by_name
      @expected_top_level_file_paths_by_name ||= expected_top_level_file_names.index_with do |file_name|
        File.join(destination_prefix, file_name)
      end
    end

    def expected_directory_paths_by_name
      @expected_directory_paths_by_name ||= expected_directory_names.index_with do |directory_name|
        File.join(destination_prefix, directory_name)
      end
    end

    def actual_top_level_file_names
      @actual_top_level_file_names ||= begin
        return Set.new if expected_top_level_file_name_set.empty?
        return Set.new if destination_storage_file_paths.empty?

        expected_top_level_file_paths_by_name.each_with_object(Set.new) do |(file_name, expected_path), set|
          set << file_name if destination_storage_file_paths.include?(expected_path)
        end
      end
    end

    def actual_expected_directory_names
      @actual_expected_directory_names ||= begin
        return Set.new if expected_directory_name_set.empty?
        return Set.new if destination_storage_paths.empty?

        expected_directory_paths_by_name.each_with_object(Set.new) do |(directory_name, expected_path), set|
          set << directory_name if storage_directory_present?(expected_path)
        end
      end
    end

    def actual_directory_file_counts
      @actual_directory_file_counts ||= begin
        counts = expected_directory_names.index_with { 0 }

        destination_storage_file_paths.each do |path|
          directory_name = extract_expected_directory_name(path)

          next unless directory_name
          next unless expected_directory_name_set.include?(directory_name)

          counts[directory_name] += 1
        end

        counts
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

    def storage_directory_present?(expected_path)
      destination_storage_paths.any? do |path|
        path == expected_path || path.start_with?("#{expected_path}/")
      end
    end

    def extract_expected_directory_name(storage_path)
      return nil unless storage_path.start_with?("#{destination_prefix}/")

      suffix = storage_path.delete_prefix("#{destination_prefix}/")
      directory_name = suffix.split("/", 2).first

      return nil if expected_top_level_file_name_set.include?(directory_name)

      directory_name
    end

    def destination_storage_paths
      @destination_storage_paths ||= begin
        return Set.new if destination_prefix.blank?

        raw_destination_storage_paths
          .map { |path| normalize_storage_path(path) }
          .reject(&:blank?)
          .to_set
      end
    end

    # ignore storage directory keys from validator count
    def destination_storage_file_paths
      @destination_storage_file_paths ||= begin
        destination_storage_paths.reject do |path|
          path == destination_prefix || destination_directory_marker_paths.include?(path)
        end.to_set
      end
    end

    def destination_directory_marker_paths
      @destination_directory_marker_paths ||= begin
        raw_destination_storage_paths
          .select { |path| directory_marker_path?(path) }
          .map { |path| normalize_storage_path(path) }
          .reject(&:blank?)
          .to_set
      end
    end

    def raw_destination_storage_paths
      @raw_destination_storage_paths ||= begin
        return [] if destination_prefix.blank?

        storage_paths_for_prefix(destination_prefix).map(&:to_s)
      end
    end

    def directory_marker_path?(path)
      path.to_s.end_with?("/")
    end

    def normalize_storage_path(path)
      path.to_s.delete_prefix("/").delete_suffix("/")
    end

    def storage_paths_for_prefix(prefix)
      storage_root.subtree_keys(prefix)
    end
  end
end