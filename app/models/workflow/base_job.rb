class Workflow::BaseJob < ActiveRecord::Base

  self.abstract_class = true
  has_one :workflow_workflow_job_relation, :class_name => 'Workflow::WorkflowJobRelation', as: :job
  has_one :workflow, through: :workflow_workflow_job_relation

end
