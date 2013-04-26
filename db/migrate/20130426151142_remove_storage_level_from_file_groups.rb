class RemoveStorageLevelFromFileGroups < ActiveRecord::Migration
  def up
    remove_column :file_groups, :storage_level
  end

  def down
    add_column :file_groups, :storage_level, :string
    FileGroup.all.each do |fg|
      level = case fg.type
        when 'ExternalFileGroup'
          'external'
        when 'BitLevelFileGroup'
          'bit-level store'
        when 'ObjectLevelFileGroup'
          'object-level store'
        else
          raise RuntimeError, "Unrecognized type for file group #{fg.id}"
      end
      fg.update_column(:storage_level, type)
    end
  end
end
