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

ActiveRecord::Schema.define(:version => 20120829153644) do

  create_table "access_system_collection_joins", :force => true do |t|
    t.integer  "access_system_id"
    t.integer  "collection_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "access_system_collection_joins", ["access_system_id"], :name => "index_access_system_collection_joins_on_access_system_id"
  add_index "access_system_collection_joins", ["collection_id"], :name => "index_access_system_collection_joins_on_collection_id"

  create_table "access_systems", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assessments", :force => true do |t|
    t.date     "date"
    t.text     "preservation_risks"
    t.text     "notes"
    t.integer  "collection_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "author_id"
  end

  add_index "assessments", ["author_id"], :name => "index_assessments_on_author_id"
  add_index "assessments", ["collection_id"], :name => "index_assessments_on_collection_id"

  create_table "collection_object_type_joins", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "object_type_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "collection_object_type_joins", ["collection_id"], :name => "index_collection_object_type_joins_on_collection_id"
  add_index "collection_object_type_joins", ["object_type_id"], :name => "index_collection_object_type_joins_on_object_type_id"

  create_table "collections", :force => true do |t|
    t.integer  "repository_id"
    t.string   "title"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "published"
    t.boolean  "ongoing"
    t.text     "description"
    t.string   "access_url"
    t.text     "file_package_summary"
    t.text     "rights_statement"
    t.text     "rights_restrictions"
    t.text     "notes"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "content_type_id"
    t.integer  "contact_id"
    t.integer  "preservation_priority_id"
    t.text     "private_description"
  end

  add_index "collections", ["contact_id"], :name => "index_collections_on_contact_id"
  add_index "collections", ["content_type_id"], :name => "index_collections_on_content_type_id"
  add_index "collections", ["repository_id"], :name => "index_collections_on_repository_id"

  create_table "content_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.integer  "storage_medium_id"
    t.integer  "file_type_id"
  end

  add_index "file_groups", ["file_type_id"], :name => "index_file_groups_on_file_type_id"
  add_index "file_groups", ["storage_medium_id"], :name => "index_file_groups_on_storage_medium_id"

  create_table "file_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ingest_statuses", :force => true do |t|
    t.string   "state"
    t.string   "staff"
    t.date     "date"
    t.text     "notes"
    t.integer  "collection_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "object_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "net_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "people", ["net_id"], :name => "index_people_on_net_id"

  create_table "preservation_priorities", :force => true do |t|
    t.string   "name"
    t.float    "priority"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "administrator_id"
  end

  add_index "production_units", ["administrator_id"], :name => "index_production_units_on_administrator_id"

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
    t.integer  "contact_id"
  end

  add_index "repositories", ["contact_id"], :name => "index_repositories_on_contact_id"

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

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "users", ["uid"], :name => "index_users_on_uid"

end
