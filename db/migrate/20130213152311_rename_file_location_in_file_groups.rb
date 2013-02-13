class RenameFileLocationInFileGroups < ActiveRecord::Migration
  def up
    rename_column :file_groups, :file_location, :external_file_location
  end

  def down
    rename_column :file_groups, :external_file_location, :file_location
  end
end
