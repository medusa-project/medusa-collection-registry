class CreateAccessSystemCollectionJoins < ActiveRecord::Migration
  def change
    create_table :access_system_collection_joins do |t|
      t.integer :access_system_id
      t.integer :collection_id

      t.timestamps
    end
    add_index :access_system_collection_joins, :access_system_id
    add_index :access_system_collection_joins, :collection_id
  end
end
