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
      missing_files =
        expected_top_level_file_names - actual_top_level_file_names.to_a

      missing_directories =
        expected_directory_names - actual_expected_directory_names.to_a

      directory_count_mismatches =
        build_directory_count_mismatches

      expected_file_count = accrual_job.total_file_count

      # Only count CFS files belonging to this accrual.
      actual_file_count =
        actual_top_level_file_names.size +
        actual_directory_file_counts.values.sum

      blocking_failures = []

      if expected_file_count != actual_file_count
        blocking_failures <<
          "Expected ingest file count does not match actual ingested file count."
      end

      if missing_files.any?
        blocking_failures <<
          "One or more expected top-level files are missing from the ingested result."
      end

      if missing_directories.any?
        blocking_failures <<
          "One or more expected accrual directories are missing from the ingested result."
      end

      if directory_count_mismatches.any?
        blocking_failures <<
          "One or more expected accrual directories have an incorrect ingested file count."
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

    def expected_directory_paths_by_name
      @expected_directory_paths_by_name ||=
        expected_directory_names.index_with do |directory_name|
          File.join(destination_prefix, directory_name)
        end
    end

    def expected_directory_paths
      @expected_directory_paths ||=
        expected_directory_paths_by_name.values
    end

    # Top-level file validation was already scoped correctly.
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
      @actual_expected_directory_names ||=
        actual_expected_directories_by_name.keys.to_set
    end

    # FIX:
    # Do not use directory.files_in_tree.count here.
    #
    # That counts historical files as well as files from this accrual.
    def actual_directory_file_counts
      @actual_directory_file_counts ||=
        expected_directory_destination_file_paths.transform_values do |expected_paths|
          (expected_paths & actual_cfs_file_path_set).size
        end
    end

    # Build the exact destination paths represented by this accrual's
    # staging contents.
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
              normalize_path(
                File.join(destination_prefix, relative_path)
              )

            paths_by_directory[directory_name] << destination_path
          end

          paths_by_directory
        end
      end
    end

    # PERFORMANCE:
    # Build the CFS file path Set once instead of calling
    # files_in_tree.count for every expected directory.
    def actual_cfs_file_path_set
      @actual_cfs_file_path_set ||= begin
        paths = Set.new

        destination_root
          .files_in_tree
          .preload(:cfs_directory)
          .find_each do |file|
            directory_path = cfs_directory_destination_path(file.cfs_directory)

            paths << normalize_path(
              File.join(directory_path, file.name)
            )
          end

        paths
      end
    end

    def cfs_directory_destination_path(directory)
      stored_path = normalize_path(directory.path)
      prefix = normalize_path(destination_prefix)

      if stored_path == prefix || stored_path.start_with?("#{prefix}/")
        stored_path
      else
        normalize_path(directory.relative_path)
      end
    end

    # Existing directory lookup
    def actual_expected_directories_by_name
      @actual_expected_directories_by_name ||= begin
        return {} if expected_directory_name_set.empty?

        expected_directory_names.each_with_object({}) do |directory_name, directories|
          directory = find_expected_directory(directory_name)

          directories[directory_name] = directory if directory
        end
      end
    end

    def find_expected_directory(directory_name)
      direct_child_directories_by_path[directory_name] ||
        root_directories_by_full_path[
          File.join(destination_prefix, directory_name)
        ]
    end

    # PERFORMANCE:
    # All expected direct children are loaded in one query.
    def direct_child_directories_by_path
      @direct_child_directories_by_path ||= begin
        CfsDirectory.where(
          parent_id: destination_root.id,
          parent_type: "CfsDirectory",
          path: expected_directory_names
        ).index_by(&:path)
      end
    end

    # Full-path fallback is also one query.
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
    # Load staging once for the entire validation.
    def raw_staging_paths
      @raw_staging_paths ||= begin
        staging_root
          .subtree_keys(staging_prefix)
          .map(&:to_s)
      end
    end

    def staging_file_paths
      @staging_file_paths ||= begin
        normalized_prefix =
          normalize_path(staging_prefix)

        directory_marker_paths =
          raw_staging_paths
            .select { |path| directory_marker_path?(path) }
            .map { |path| normalize_path(path) }
            .to_set

        raw_staging_paths
          .map { |path| normalize_path(path) }
          .reject(&:blank?)
          .reject { |path| path == normalized_prefix }
          .reject { |path| directory_marker_paths.include?(path) }
          .to_set
      end
    end

    def relative_staging_path(source_path)
      source_path = normalize_path(source_path)
      prefix = normalize_path(staging_prefix)

      return source_path if prefix.blank?

      source_path.delete_prefix("#{prefix}/")
    end

    def directory_marker_path?(path)
      path.to_s.end_with?("/")
    end

    def normalize_path(path)
      path.to_s
          .delete_prefix("/")
          .delete_suffix("/")
    end
  end
end