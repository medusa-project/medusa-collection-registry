class AddBookTrackerTasksTable < ActiveRecord::Migration
  def change
    create_table "book_tracker_tasks", force: true do |t|
      t.string   "name"
      t.decimal  "service",          precision: 1, scale: 0
      t.decimal  "status",           precision: 1, scale: 0
      t.decimal  "pid",              precision: 6, scale: 0
      t.float    "percent_complete",                         default: 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "completed_at"
    end
  end
end
