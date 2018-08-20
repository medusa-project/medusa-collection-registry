class RemoveExternalIdFromFileGroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :file_groups, :external_id
  end
end
