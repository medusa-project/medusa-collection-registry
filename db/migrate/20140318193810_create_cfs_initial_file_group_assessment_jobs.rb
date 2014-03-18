class CreateCfsInitialFileGroupAssessmentJobs < ActiveRecord::Migration
  def change
    create_table :job_cfs_initial_file_group_assessments do |t|
      t.integer :file_group_id
    end
    add_index :job_cfs_initial_file_group_assessments, :file_group_id
  end
end
