class CreateCfsFiles < ActiveRecord::Migration
  def change
    create_table :cfs_files do |t|
      t.integer :cfs_directory_id
      t.string :name
    end
    add_index :cfs_files, :cfs_directory_id
    add_index :cfs_files, :name
  end
end
