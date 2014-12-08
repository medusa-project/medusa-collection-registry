class RemoveFileTypes < ActiveRecord::Migration
  def change
    remove_column :file_groups, :file_type_id
    drop_table :file_types
  end
end
