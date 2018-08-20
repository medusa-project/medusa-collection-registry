class RemoveContactIdFromFileGroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :file_groups, :contact_id
  end
end
