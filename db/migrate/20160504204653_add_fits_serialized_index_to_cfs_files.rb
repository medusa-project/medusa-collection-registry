class AddFitsSerializedIndexToCfsFiles < ActiveRecord::Migration
  def change
    add_index :cfs_files, :fits_serialized
  end
end
