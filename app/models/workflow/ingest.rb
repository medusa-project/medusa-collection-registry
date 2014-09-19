class Workflow::Ingest < Workflow::Base
  belongs_to :external_file_group_id
  belongs_to :bit_level_file_group_id
  belongs_to :user_id
end
