class RenameTaskToTaskElement < ActiveRecord::Migration[5.2]
  def change
    rename_table :assessor_tasks, :assessor_task_elements
  end
end
