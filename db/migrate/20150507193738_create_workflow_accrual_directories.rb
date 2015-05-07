class CreateWorkflowAccrualDirectories < ActiveRecord::Migration
  def change
    create_table :workflow_accrual_directories do |t|
      t.references :workflow_accrual_job, index: true
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :workflow_accrual_directories, :workflow_accrual_jobs
    add_index :workflow_accrual_directories, [:workflow_accrual_job_id, :name], unique: true, name: :wfad_job_and_name_idx
  end
end
