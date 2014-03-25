class CreateJobFitsDirectories < ActiveRecord::Migration
  def change
    create_table :job_fits_directories do |t|
      t.integer :cfs_directory_id
      t.integer :file_group_id
      t.integer :file_count

      t.timestamps
    end
    add_index :job_fits_directories, :cfs_directory_id
    add_index :job_fits_directories, :file_group_id
  end
end
