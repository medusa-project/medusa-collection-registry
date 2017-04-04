class AddCfsDirectoryToItems < ActiveRecord::Migration
  def change
    add_reference :items, :cfs_directory, index: true
  end
end
