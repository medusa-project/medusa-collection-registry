class DeleteWorkflowWorkflowJobRelations < ActiveRecord::Migration
  def change
    drop_table :workflow_workflow_job_relations
  end
end
