class AddSentAtToAssessorTask < ActiveRecord::Migration[5.2]
  def change
    add_column :assessor_tasks, :sent_at, :datetime
  end
end
