class AddFitsSerializedToCfsFiles < ActiveRecord::Migration
  def change
    add_column :cfs_files, :fits_serialized, :boolean, null: false, default: false
  end
end
