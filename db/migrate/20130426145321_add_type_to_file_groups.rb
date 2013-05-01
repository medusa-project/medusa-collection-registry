class AddTypeToFileGroups < ActiveRecord::Migration
  def up
    add_column :file_groups, :type, :string
    add_index :file_groups, :type
    FileGroup.all.each do |fg|
      type = case fg.attributes['storage_level']
        when 'external'
          'ExternalFileGroup'
        when 'bit-level store'
          'BitLevelFileGroup'
        when 'object-level store'
          'ObjectLevelFileGroup'
        else
          raise RuntimeError, "Unrecognized storage level for file group #{fg.id}"
      end
      fg.update_column(:type, type)
    end
  end

  def down
    remove_column :file_groups, :type
  end
end
