class AddNameAndStorageLevelToFileGroups < ActiveRecord::Migration
  def up
    add_column :file_groups, :name, :string
    add_column :file_groups, :storage_level, :string
    FileGroup.all.each do |file_group|
      file_group.name ||= "File group #{file_group.id}"
      file_group.storage_level ||= 'external'
      file_group.save!
    end
  end

  def down
    remove_column :file_groups, :name
    remove_column :file_groups, :storage_level
  end
end
