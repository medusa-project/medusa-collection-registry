class CreateCfsInitialDirectoryAssessmentJobs < ActiveRecord::Migration
  def change
    create_table :job_cfs_initial_directory_assessments do |t|
      t.integer :file_group_id
      t.integer :cfs_directory_id
      t.integer :file_count
    end
    add_index :job_cfs_initial_directory_assessments, :file_group_id
    add_index :job_cfs_initial_directory_assessments, :cfs_directory_id
  end
end
