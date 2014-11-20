class AddUpdatedAtIndexes < ActiveRecord::Migration
  def change
    add_timestamps = [:amazon_backups, :institutions]
    add_updated_at_index = add_timestamps +
        [:access_system_collection_joins, :access_systems, :assessments, :attachments, :collection_resource_type_joins,
         :collections, :events, :file_groups, :file_types, :job_virus_scans, :package_profiles, :people,
         :preservation_priorities, :producers, :red_flags, :related_file_group_joins, :repositories,
         :resource_types, :rights_declarations, :scheduled_events, :storage_media, :users, :virus_scans, :workflow_ingests]
    add_timestamps.each do |table|
      add_timestamps(table)
      klass = Kernel.const_get(table.to_s.singularize.camelize)
      klass.update_all created_at: Time.now, updated_at: Time.now
    end
    add_updated_at_index.each do |table|
      add_index table, :updated_at
    end
  end
end
