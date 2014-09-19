class CreateWorkflowWorkflowJobRelations < ActiveRecord::Migration
  def change
    create_table :workflow_workflow_job_relations do |t|
      t.references :workflow, polymorphic: true
      t.references :job, polymorphic: true
      t.timestamps
    end
    #the default names are too long, so do manually
    add_index :workflow_workflow_job_relations, :workflow_id, name: 'workflow_relation_id'
    add_index :workflow_workflow_job_relations, :workflow_type, name: 'workflow_relation_type'
    add_index :workflow_workflow_job_relations, :job_id, name: 'job_relation_id'
    add_index :workflow_workflow_job_relations, :job_type, name: 'job_relation_type'
  end
end
