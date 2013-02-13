class AddStagedFileLocationToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :staged_file_location, :string
  end
end
