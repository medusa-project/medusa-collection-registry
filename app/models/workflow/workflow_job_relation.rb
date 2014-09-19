class Workflow::WorkflowJobRelation < ActiveRecord::Base
  belongs_to :workflow, polymorphic: true
  belongs_to :job, polymorphic: true
end
