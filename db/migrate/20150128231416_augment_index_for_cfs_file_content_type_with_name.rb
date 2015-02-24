class AugmentIndexForCfsFileContentTypeWithName < ActiveRecord::Migration
  def change
    remove_index :cfs_files, :content_type_id
    add_index :cfs_files, [:content_type_id, :name]
  end
end
