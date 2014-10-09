# Create (in start state) and enqueue
# - change to copying state, copy directory, reenqueue
# - change to backing up state, register amazon backup, do not reenqueue
# - when backup is complete, it will call back to finish process
class Workflow::Ingest < Workflow::Base
  belongs_to :external_file_group
  belongs_to :bit_level_file_group
  belongs_to :user
  belongs_to :amazon_backup

end
