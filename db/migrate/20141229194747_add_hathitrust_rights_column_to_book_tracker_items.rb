class AddHathitrustRightsColumnToBookTrackerItems < ActiveRecord::Migration
  def change
    add_column :book_tracker_items, :hathitrust_rights, :string
  end
end
