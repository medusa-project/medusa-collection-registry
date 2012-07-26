class AddKeyIndexes < ActiveRecord::Migration
  def up
    add_index :collections, :repository_id
    add_index :assessments, :collection_id
  end

  def down
    remove_index :collections, :repository_id
    remove_index :assessments, :collection_id
  end
end
