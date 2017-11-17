class AddMd5SumIndexToCfsFiles < ActiveRecord::Migration[5.1]
  def change
    add_index :cfs_files, :md5_sum
  end
end
