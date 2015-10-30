class RemoveWorkflowFieldsFromItems < ActiveRecord::Migration
  def change
    remove_columns :items, :tif_completed, :qa_tif, :transferred_to_medusa, :transferred_to_hathi
  end
end
