class MakeExternalFileGroupIdIndexUniqueOnWorkflowIngests < ActiveRecord::Migration
  def change
    remove_index :workflow_ingests, :external_file_group_id
    add_index :workflow_ingests, :external_file_group_id, unique: true
  end
end
