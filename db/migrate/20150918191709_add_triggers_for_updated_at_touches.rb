require 'trigger_helpers'
#This is to replace all existing association 'touch' operations by database triggers
#I'll try to build up the machinery for this in such a way that it can be reused for adding
#additional touches as needed.
#Simple touches should be pretty easy; polymorphic ones will require additional care.
class AddTriggersForUpdatedAtTouches < ActiveRecord::Migration
  include TriggerHelpers

  SIMPLE_TOUCHES = {cfs_files: [:file_extensions, :content_types, :cfs_directories],
                    access_system_collection_joins: [:access_systems, :collections],
                    amazon_backups: [:cfs_directories, :users],
                    assessments: :storage_media,
                    collections: [:repositories, :preservation_priorities],
                    file_groups: [:collections, :producers, :package_profiles],
                    repositories: :institutions,
                    resource_typeable_resource_type_joins: :resource_types,
                    virus_scans: :file_groups,
                    job_cfs_directory_exports: [:users, :cfs_directories],
                    job_cfs_initial_file_group_assessments: :file_groups,
                    job_fits_directories: [:file_groups, :cfs_directories],
                    job_fits_directory_trees: [:file_groups, :cfs_directories],
                    job_ingest_staging_deletes: :users,
                    job_virus_scans: :file_groups,
                    workflow_accrual_jobs: [:cfs_directories, :users, :amazon_backups],
                    workflow_ingests: [:users, :amazon_backups]
  }

  NEED_TIMESTAMPS = [:job_cfs_directory_exports, :job_cfs_initial_file_group_assessments, :job_ingest_staging_deletes]

  def up
    NEED_TIMESTAMPS.each do |table|
      add_timestamps(table, null: false)
    end
    SIMPLE_TOUCHES.each do |source, targets|
      Array.wrap(targets).each do |target|
        drop_simple_touch_trigger(source, target)
        create_simple_touch_trigger_function(source, target)
        create_simple_touch_trigger(source, target)
      end
    end
  end

  def down
    SIMPLE_TOUCHES.each do |source, targets|
      Array.wrap(targets).each do |target|
        drop_simple_touch_trigger(source, target)
      end
    end
    NEED_TIMESTAMPS.each do |table|
      remove_timestamps(table, null: false)
    end
  end


end
