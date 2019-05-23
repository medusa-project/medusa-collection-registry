class AddCollectionUuidToFileGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :file_groups, :collection_uuid, :string
    FileGroup.all.find_each do |file_group|
      file_group.update_attribute(:collection_uuid, file_group.collection.uuid)
    end
  end
end
