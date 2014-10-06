class Workflow::Ingest < Workflow::Base
  belongs_to :external_file_group
  belongs_to :bit_level_file_group
  belongs_to :user
end
