class RenameAssessorTaskId < ActiveRecord::Migration[5.2]
  def change
    rename_column :assessor_responses, :assessor_task_id, :assessor_task_element_id
    rename_column :assessor_task_elements, :mediatype, :content_type
  end
end
