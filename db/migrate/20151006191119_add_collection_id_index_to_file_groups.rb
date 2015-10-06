class AddCollectionIdIndexToFileGroups < ActiveRecord::Migration
  def change
    add_index :file_groups, :collection_id
  end
end
