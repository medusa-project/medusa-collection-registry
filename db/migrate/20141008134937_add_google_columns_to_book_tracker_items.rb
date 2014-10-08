class AddGoogleColumnsToBookTrackerItems < ActiveRecord::Migration
  def change
    add_column :book_tracker_items, :exists_in_google, :boolean, default: false
  end
end
