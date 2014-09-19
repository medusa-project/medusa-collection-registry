class CreateWorkflowWorkflowJobRelations < ActiveRecord::Migration
  def change
    create_table :workflow_workflow_job_relations do |t|
      t.references :workflow, polymorphic: true, index: true
      t.references :job, polymorphic: true, index: true

      t.timestamps
    end
  end
end
