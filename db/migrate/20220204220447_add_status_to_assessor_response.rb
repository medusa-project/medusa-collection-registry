class AddStatusToAssessorResponse < ActiveRecord::Migration[5.2]
  def change
    add_column :assessor_responses, :status, :string
  end
end
