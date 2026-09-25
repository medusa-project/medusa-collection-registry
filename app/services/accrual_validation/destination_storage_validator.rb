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
      missing_files =
        expected_top_level_file_names - actual_top_level_file_names.to_a

      missing_directories =
        expected_directory_names - actual_expected_directory_names.to_a

      directory_count_mismatches =
        build_directory_count_mismatches

      expected_file_count = accrual_job.total_file_count

      # Only count files expected from this accrual.
      # Historical files already in an existing destination directory
      # are intentionally ignored.
      actual_file_count =
        actual_top_level_file_names.size +
        actual_directory_file_counts.values.sum

      blocking_failures = []

      if destination_root.blank?
        blocking_failures <<
          "Accrual job does not have a destination CFS directory."
      end

      if destination_prefix.blank?
        blocking_failures <<
          "Accrual destination does not have a valid relative path."
      end

      if expected_file_count != actual_file_count
        blocking_failures <<
          "Expected storage file count does not match actual destination storage file count."
      end

      if missing_files.any?
        blocking_failures <<
          "One or more expected top-level files are missing from destination storage."
      end

      if missing_directories.any?
        blocking_failures <<
          "One or more expected accrual directories are missing from destination storage."
      end

      if directory_count_mismatches.any?
        blocking_failures <<
          "One or more expected accrual directories have an incorrect destination storage file count."
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
      @expected_top_level_file_names ||=
        accrual_job.workflow_accrual_files.pluck(:name)
    end

    def expected_top_level_file_name_set
      @expected_top_level_file_name_set ||=
        expected_top_level_file_names.to_set
    end

    def expected_directories
      @expected_directories ||=
        accrual_job.workflow_accrual_directories.pluck(:name, :count)
    end

    def expected_directory_names
      @expected_directory_names ||=
        expected_directories.map(&:first)
    end

    def expected_directory_name_set
      @expected_directory_name_set ||=
        expected_directory_names.to_set
    end

    def expected_directory_counts
      @expected_directory_counts ||=
        expected_directories.to_h
    end

    def expected_top_level_file_paths_by_name
      @expected_top_level_file_paths_by_name ||=
        expected_top_level_file_names.index_with do |file_name|
          File.join(destination_prefix, file_name)
        end
    end

    def expected_directory_paths_by_name
      @expected_directory_paths_by_name ||=
        expected_directory_names.index_with do |directory_name|
          File.join(destination_prefix, directory_name)
        end
    end

    # Top-level validation was already correctly scoped to expected names.
    def actual_top_level_file_names
      @actual_top_level_file_names ||= begin
        return Set.new if expected_top_level_file_name_set.empty?
        return Set.new if destination_storage_file_paths.empty?

        expected_top_level_file_paths_by_name.each_with_object(Set.new) do |(file_name, expected_path), set|
          set << file_name if destination_storage_file_path_set.include?(expected_path)
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

    # FIX:
    # Only count destination paths belonging to this accrual.
    #
    # Set intersection avoids repeatedly scanning the whole destination tree.
    def actual_directory_file_counts
      @actual_directory_file_counts ||=
        expected_directory_destination_file_paths.transform_values do |expected_paths|
          (expected_paths & destination_storage_file_path_set).size
        end
    end

    # Build the exact destination paths represented by this accrual's
    # staging directory contents.
    #
    # Staging is read once, then grouped in memory by expected directory.
    def expected_directory_destination_file_paths
      @expected_directory_destination_file_paths ||= begin
        if expected_directory_name_set.empty?
          {}
        else
          paths_by_directory =
            expected_directory_names.index_with { Set.new }

          staging_file_paths.each do |source_path|
            relative_path = relative_staging_path(source_path)

            next if relative_path.blank?
            next unless relative_path.include?("/")

            directory_name = relative_path.split("/", 2).first
            next unless expected_directory_name_set.include?(directory_name)

            destination_path =
              normalize_storage_path(
                File.join(destination_prefix, relative_path)
              )

            paths_by_directory[directory_name] << destination_path
          end

          paths_by_directory
        end
      end
    end

    def build_directory_count_mismatches
      expected_directory_counts.each_with_object([]) do |(directory_name, expected_count), mismatches|
        actual_count =
          actual_directory_file_counts.fetch(directory_name, 0)

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
        path == expected_path ||
          path.start_with?("#{expected_path}/")
      end
    end

    # Destination storage is loaded once.
    def destination_storage_paths
      @destination_storage_paths ||= begin
        return Set.new if destination_prefix.blank?

        raw_destination_storage_paths
          .map { |path| normalize_storage_path(path) }
          .reject(&:blank?)
          .to_set
      end
    end

    # Ignore storage directory-marker objects when counting files.
    def destination_storage_file_paths
      @destination_storage_file_paths ||= begin
        destination_storage_paths.reject do |path|
          path == normalize_storage_path(destination_prefix) ||
            destination_directory_marker_paths.include?(path)
        end.to_set
      end
    end

    def destination_storage_file_path_set
      @destination_storage_file_path_set ||=
        destination_storage_file_paths.to_set
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

    # Reuse AccrualJob's existing staging resolution.
    def staging_root_and_prefix
      @staging_root_and_prefix ||=
        accrual_job.send(:staging_root_and_prefix)
    end

    def staging_root
      staging_root_and_prefix.first
    end

    def staging_prefix
      staging_root_and_prefix.last
    end

    # PERFORMANCE:
    # One staging listing for the whole validator, not one per directory.
    def raw_staging_storage_paths
      @raw_staging_storage_paths ||= begin
        staging_root
          .subtree_keys(staging_prefix)
          .map(&:to_s)
      end
    end

    def staging_file_paths
      @staging_file_paths ||= begin
        normalized_prefix =
          normalize_storage_path(staging_prefix)

        directory_markers =
          raw_staging_storage_paths
            .select { |path| directory_marker_path?(path) }
            .map { |path| normalize_storage_path(path) }
            .to_set

        raw_staging_storage_paths
          .map { |path| normalize_storage_path(path) }
          .reject(&:blank?)
          .reject { |path| path == normalized_prefix }
          .reject { |path| directory_markers.include?(path) }
          .to_set
      end
    end

    def relative_staging_path(source_path)
      source_path = normalize_storage_path(source_path)
      prefix = normalize_storage_path(staging_prefix)

      return source_path if prefix.blank?

      source_path.delete_prefix("#{prefix}/")
    end

    def directory_marker_path?(path)
      path.to_s.end_with?("/")
    end

    def normalize_storage_path(path)
      path.to_s
          .delete_prefix("/")
          .delete_suffix("/")
    end

    def storage_paths_for_prefix(prefix)
      storage_root.subtree_keys(prefix)
    end
  end
end