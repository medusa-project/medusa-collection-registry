class AddHathiTrustAccessColumnToBookTrackerItems < ActiveRecord::Migration[5.1]
  def change
    add_column :book_tracker_items, :hathitrust_access, :string
    add_index :book_tracker_items, :hathitrust_access
  end
end
