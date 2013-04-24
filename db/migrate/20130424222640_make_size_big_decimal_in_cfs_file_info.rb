class MakeSizeBigDecimalInCfsFileInfo < ActiveRecord::Migration
  def up
    change_column :cfs_file_infos, :size, :decimal
  end

  def down
    change_column :cfs_file_infos, :size, :integer
  end
end
