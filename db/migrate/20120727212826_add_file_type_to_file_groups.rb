class AddFileTypeToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :file_type_id, :integer
    add_index :file_groups, :file_type_id
  end
end
