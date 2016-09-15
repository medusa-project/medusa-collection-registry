class RedoFitsSerializedIndexOnCfsFiles < ActiveRecord::Migration
  def change
    remove_index :cfs_files, :fits_serialized
    add_index :cfs_files, [:fits_serialized, :id]
  end
end
