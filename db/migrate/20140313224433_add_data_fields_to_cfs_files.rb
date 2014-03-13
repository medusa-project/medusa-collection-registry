class AddDataFieldsToCfsFiles < ActiveRecord::Migration
  def change
    add_column :cfs_files, :size, :decimal
    add_index :cfs_files, :size
    add_column :cfs_files, :fits_xml, :text
    add_column :cfs_files, :mtime, :datetime
    add_index :cfs_files, :mtime
    add_column :cfs_files, :md5_sum, :string
    add_column :cfs_files, :content_type, :string
    add_index :cfs_files, :content_type
  end
end
