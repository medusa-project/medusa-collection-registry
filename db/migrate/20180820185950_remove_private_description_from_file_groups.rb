class RemovePrivateDescriptionFromFileGroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :file_groups, :private_description
  end
end
