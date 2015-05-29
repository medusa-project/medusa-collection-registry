class CreateWorkflowAccrualComments < ActiveRecord::Migration
  def change
    create_table :workflow_accrual_comments do |t|
      t.references :workflow_accrual_job, index: true
      t.text :body
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :workflow_accrual_comments, :workflow_accrual_jobs
    add_foreign_key :workflow_accrual_comments, :users
  end
end
