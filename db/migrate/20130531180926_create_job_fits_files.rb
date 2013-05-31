class CreateJobFitsFiles < ActiveRecord::Migration
  def change
    create_table :job_fits_files do |t|
      t.string :path
      t.integer :fits_directory_tree_id

      t.timestamps
    end
    add_index :job_fits_files, :fits_directory_tree_id
  end
end
