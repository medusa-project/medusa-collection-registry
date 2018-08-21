class RemoveFileFormatFromFileGroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :file_groups, :file_format
  end
end
