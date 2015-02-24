class AddFileExtensionIdToCfsFiles < ActiveRecord::Migration
  def change
    add_reference :cfs_files, :file_extension
    add_foreign_key :cfs_files, :file_extensions
    add_index :cfs_files, [:file_extension_id, :name]
  end
end
