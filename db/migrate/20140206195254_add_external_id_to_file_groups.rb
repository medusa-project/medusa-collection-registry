class AddExternalIdToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :external_id, :string
    add_index :file_groups, :external_id
  end
end
