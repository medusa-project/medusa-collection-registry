class CreateWorkflowAccrualKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :workflow_accrual_keys do |t|
      t.text :key
      t.references :workflow_accrual_job
    end
  end
end
