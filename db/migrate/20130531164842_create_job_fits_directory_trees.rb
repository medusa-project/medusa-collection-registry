class CreateJobFitsDirectoryTrees < ActiveRecord::Migration
  def change
    create_table :job_fits_directory_trees do |t|
      t.string :path

      t.timestamps
    end
  end
end
