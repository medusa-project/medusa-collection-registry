class AddIndexesToContentType < ActiveRecord::Migration
  def change
    add_foreign_key :cfs_files, :content_types
    add_index :content_types, :name, unique: true
  end
end
