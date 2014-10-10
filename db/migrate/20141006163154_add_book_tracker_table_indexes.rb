class AddBookTrackerTableIndexes < ActiveRecord::Migration
  def change
    add_index :book_tracker_items, :author
    add_index :book_tracker_items, :bib_id
    add_index :book_tracker_items, :date
    add_index :book_tracker_items, :exists_in_hathitrust
    add_index :book_tracker_items, :exists_in_internet_archive
    add_index :book_tracker_items, :ia_identifier
    add_index :book_tracker_items, :obj_id
    add_index :book_tracker_items, :oclc_number
    add_index :book_tracker_items, :title
    add_index :book_tracker_items, :volume
  end
end
