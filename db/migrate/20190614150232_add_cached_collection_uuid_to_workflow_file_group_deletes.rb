class AddCachedCollectionUuidToWorkflowFileGroupDeletes < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_file_group_deletes, :cached_collection_uuid, :string
    add_index :workflow_file_group_deletes, :cached_collection_uuid
    Workflow::FileGroupDelete.all.each do |file_group_delete|
      file_group_delete.cached_collection_uuid = file_group_delete.collection.uuid
      file_group_delete.save!
    end
  end
end
