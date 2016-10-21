class CreateSubcollectionJoins < ActiveRecord::Migration
  def change
    create_table :subcollection_joins do |t|
      t.integer :parent_collection_id, null: false, index: true
      t.integer :child_collection_id, null: false, index: true
    end
  end
end
