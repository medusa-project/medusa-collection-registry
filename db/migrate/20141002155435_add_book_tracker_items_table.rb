class AddBookTrackerItemsTable < ActiveRecord::Migration
  def change
    create_table "book_tracker_items", force: true do |t|
      t.integer  "bib_id"
      t.string   "oclc_number"
      t.string   "obj_id"
      t.string   "title"
      t.string   "author"
      t.string   "volume"
      t.string   "date"
      t.boolean  "exists_in_hathitrust",       default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ia_identifier"
      t.boolean  "exists_in_internet_archive", default: false
      t.text     "raw_marcxml"
    end
  end
end
