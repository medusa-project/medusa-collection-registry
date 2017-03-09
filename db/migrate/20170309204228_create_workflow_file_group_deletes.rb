class CreateWorkflowFileGroupDeletes < ActiveRecord::Migration
  def change
    create_table :workflow_file_group_deletes do |t|
      t.integer :requester_id, index: true
      t.integer :approver_id, index: true
      t.integer :file_group_id, index: true
      t.string :state, index: true
      t.text :requester_reason
      t.text :approver_reason
      t.string :cached_file_group_title

      t.timestamps null: false
    end
  end
end
