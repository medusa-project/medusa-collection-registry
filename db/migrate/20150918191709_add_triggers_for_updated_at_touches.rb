require 'simple_trigger_helper'
#This is to replace all existing association 'touch' operations by database triggers
#I'll try to build up the machinery for this in such a way that it can be reused for adding
#additional touches as needed.
#We omit adding these for the polymorphic cases, as the advantage seems overshadowed by the added
#complexity. In these cases typically the Rails touch fire and then in the owning model one of these
#simpler touches may trigger, so most of the database work will still be saved in any case.
class AddTriggersForUpdatedAtTouches < ActiveRecord::Migration

  SIMPLE_TOUCHES = {
      cfs_files: [:file_extensions, :content_types, :cfs_directories],
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
      workflow_accrual_comments: [:workflow_accrual_jobs],
      workflow_accrual_conflicts: [:workflow_accrual_jobs],
      workflow_accrual_directories: [:workflow_accrual_jobs],
      workflow_accrual_files: [:workflow_accrual_jobs],
      workflow_ingests: [:users, :amazon_backups]
  }

  #In these the outer key is still the source table. The inner key is the id for the join (without _id) and
  #the inner value is the true target table.
  TOUCHES_WITH_DIFFERENT_TABLE_NAMES = {
    related_file_group_joins: {source_file_group: :file_groups, target_file_group: :file_groups},
    job_ingest_staging_deletes: {external_file_group: :file_groups},
    workflow_ingests: {external_file_group: :file_groups, bit_level_file_group: :file_groups}
  }

  NEED_TIMESTAMPS = [:job_cfs_directory_exports, :job_cfs_initial_file_group_assessments, :job_ingest_staging_deletes]

  def up
    NEED_TIMESTAMPS.each do |table|
      add_timestamps(table, null: false)
    end
    SIMPLE_TOUCHES.each do |source, targets|
      Array.wrap(targets).each do |target|
        SimpleTriggerHelper.new(source_table: source, target_table: target).create_trigger
      end
    end
    TOUCHES_WITH_DIFFERENT_TABLE_NAMES.each do |source, target_hash|
      target_hash.each do |association, target|
        SimpleTriggerHelper.new(source_table: source, target_table: target, association: association).create_trigger
      end
    end
  end

  def down
    SIMPLE_TOUCHES.each do |source, targets|
      Array.wrap(targets).each do |target|
        SimpleTriggerHelper.new(source_table: source, target_table: target).drop_trigger
      end
    end
    TOUCHES_WITH_DIFFERENT_TABLE_NAMES.each do |source, target_hash|
      target_hash.each do |association, target|
        SimpleTriggerHelper.new(source_table: source, target_table: target, association: association).drop_trigger
      end
    end
    NEED_TIMESTAMPS.each do |table|
      remove_timestamps(table, null: false)
    end
  end

end
