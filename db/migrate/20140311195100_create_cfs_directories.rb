class CreateCfsDirectories < ActiveRecord::Migration
  def change
    create_table :cfs_directories do |t|
      t.text :path
      t.integer :parent_cfs_directory_id
    end
    add_index :cfs_directories, :path
    add_index :cfs_directories, :parent_cfs_directory_id
  end
end
