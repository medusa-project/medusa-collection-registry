class CreateCollectionResourceTypeJoins < ActiveRecord::Migration
  def change
    create_table :collection_resource_type_joins do |t|
      t.integer :collection_id
      t.integer :resource_type_id

      t.timestamps
    end
    add_index :collection_resource_type_joins, :collection_id
    add_index :collection_resource_type_joins, :resource_type_id
  end
end
