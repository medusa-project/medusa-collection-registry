class CreateWorkflowAccrualJobs < ActiveRecord::Migration
  def change
    create_table :workflow_accrual_jobs do |t|
      t.references :cfs_directory, index: true
      t.text :staging_path
      t.string :state
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :workflow_accrual_jobs, :cfs_directories
    add_foreign_key :workflow_accrual_jobs, :users
    add_index :workflow_accrual_jobs, [:cfs_directory_id, :staging_path], unique: true, name: :wfaj_cfs_dir_id_and_staging_path_idx
  end
end
