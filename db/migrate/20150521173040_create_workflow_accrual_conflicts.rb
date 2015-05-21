class CreateWorkflowAccrualConflicts < ActiveRecord::Migration
  def change
    create_table :workflow_accrual_conflicts do |t|
      t.references :workflow_accrual_job, index: true
      t.text :path
      t.boolean :different, index: true

      t.timestamps null: false
    end
    add_foreign_key :workflow_accrual_conflicts, :workflow_accrual_jobs
  end
end
