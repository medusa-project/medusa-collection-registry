class RemoveBookTrackerTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :book_tracker_items
    drop_table :book_tracker_tasks
  end
end
