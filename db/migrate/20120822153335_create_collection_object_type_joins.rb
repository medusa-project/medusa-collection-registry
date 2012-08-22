class CreateCollectionObjectTypeJoins < ActiveRecord::Migration
  def change
    create_table :collection_object_type_joins do |t|
      t.integer :collection_id
      t.integer :object_type_id

      t.timestamps
    end
    add_index :collection_object_type_joins, :collection_id
    add_index :collection_object_type_joins, :object_type_id
  end
end
