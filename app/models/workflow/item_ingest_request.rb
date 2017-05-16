class Workflow::ItemIngestRequest < ApplicationRecord
  belongs_to :workflow_project_item_ingest, :class_name => 'Workflow::ProjectItemIngest'
  belongs_to :item
end
