class CreateWorkflowGlobusTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :workflow_globus_transfers do |t|
      t.references :workflow_accrual_key
      t.string :source_uuid, null: false
      t.string :destination_uuid, null: false
      t.string :source_path, null: false
      t.string :destination_path, null: false
      t.boolean :recursive, default: false
      t.string :task_id
      t.string :task_link
      t.string :request_id

      t.timestamps
    end
  end
end
