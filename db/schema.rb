# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120727190840) do

  create_table "assessments", :force => true do |t|
    t.date     "date"
    t.text     "preservation_risks"
    t.text     "notes"
    t.integer  "collection_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "assessments", ["collection_id"], :name => "index_assessments_on_collection_id"

  create_table "collections", :force => true do |t|
    t.integer  "repository_id"
    t.string   "title"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "published"
    t.boolean  "ongoing"
    t.text     "description"
    t.text     "access_url"
    t.text     "file_package_summary"
    t.text     "rights_statement"
    t.text     "rights_restrictions"
    t.text     "notes"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "collections", ["repository_id"], :name => "index_collections_on_repository_id"

  create_table "file_groups", :force => true do |t|
    t.string   "file_location"
    t.string   "file_format"
    t.decimal  "total_file_size"
    t.integer  "total_files"
    t.integer  "collection_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.date     "last_access_date"
    t.integer  "production_unit_id"
  end

  create_table "production_units", :force => true do |t|
    t.string   "title"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone_number"
    t.string   "email"
    t.string   "url"
    t.text     "notes"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "repositories", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "notes"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone_number"
    t.string   "email"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "storage_media", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
