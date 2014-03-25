class AlterJobsFitsDirectoryTree < ActiveRecord::Migration
  def change
    remove_column :job_fits_directory_trees, :path
    add_column :job_fits_directory_trees, :cfs_directory_id, :integer
    add_column :job_fits_directory_trees, :file_group_id, :integer
    add_index :job_fits_directory_trees, :cfs_directory_id
    add_index :job_fits_directory_trees, :file_group_id
  end
end
