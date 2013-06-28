class RemoveDirectories < ActiveRecord::Migration
  def up
    drop_table :directories
  end

  def down
    create_table :directories do |t|
      t.string :name
      t.integer :parent_id
      t.integer :collection_id

      t.timestamps
    end
    add_index :directories, :parent_id
    add_index :directories, :collection_id
  end
end
