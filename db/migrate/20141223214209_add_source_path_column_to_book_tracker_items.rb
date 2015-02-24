class AddSourcePathColumnToBookTrackerItems < ActiveRecord::Migration
  def change
    add_column :book_tracker_items, :source_path, :text
  end
end
