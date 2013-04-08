class AddBasicFieldsToCfsFileInfos < ActiveRecord::Migration
  def change
    add_column :cfs_file_infos, :size, :integer
    add_column :cfs_file_infos, :md5_sum, :string
    add_column :cfs_file_infos, :content_type, :string

    add_index :cfs_file_infos, :content_type
  end
end
