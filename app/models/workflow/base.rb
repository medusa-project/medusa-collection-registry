class Workflow::Base < ActiveRecord::Base

  self.abstract_class = true
  has_one :workflow_workflow_job_relation, :class_name => 'Workflow::WorkflowJobRelation', as: :workflow
  has_one :job, through: :workflow_workflow_job_relation

end
