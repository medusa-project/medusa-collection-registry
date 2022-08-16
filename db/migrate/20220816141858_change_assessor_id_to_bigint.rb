class ChangeAssessorIdToBigint < ActiveRecord::Migration[7.0]
  def change
    change_column :assessor_task_elements, :id, :bigint, null: false, unique: true
  end
end
