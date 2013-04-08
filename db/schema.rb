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

ActiveRecord::Schema.define(:version => 20130408151257) do

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
    t.integer  "assessable_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "author_id"
    t.text     "notes_html"
    t.text     "preservation_risks_html"
    t.string   "assessable_type"
    t.string   "name"
    t.string   "assessment_type"
    t.string   "preservation_risk_level"
    t.text     "naming_conventions"
    t.text     "naming_conventions_html"
    t.integer  "storage_medium_id"
    t.text     "directory_structure"
    t.text     "directory_structure_html"
    t.date     "last_access_date"
    t.string   "file_format"
    t.decimal  "total_file_size"
    t.integer  "total_files"
  end

  add_index "assessments", ["assessable_id"], :name => "index_assessments_on_collection_id"
  add_index "assessments", ["author_id"], :name => "index_assessments_on_author_id"

  create_table "bit_files", :force => true do |t|
    t.integer  "directory_id"
    t.string   "md5sum"
    t.string   "name"
    t.string   "dx_name"
    t.string   "content_type"
    t.boolean  "dx_ingested",  :default => false
    t.integer  "size"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.text     "fits_xml"
  end

  add_index "bit_files", ["content_type"], :name => "index_bit_files_on_content_type"
  add_index "bit_files", ["directory_id"], :name => "index_bit_files_on_directory_id"
  add_index "bit_files", ["dx_name"], :name => "index_bit_files_on_dx_name"
  add_index "bit_files", ["name"], :name => "index_bit_files_on_name"

  create_table "cache_ldap_groups", :force => true do |t|
    t.integer  "user_id"
    t.string   "group"
    t.string   "domain"
    t.boolean  "member"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "cache_ldap_groups", ["created_at"], :name => "index_cache_ldap_groups_on_created_at"
  add_index "cache_ldap_groups", ["user_id"], :name => "index_cache_ldap_groups_on_user_id"

  create_table "cfs_file_infos", :force => true do |t|
    t.string   "path"
    t.text     "fits_xml"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "size"
    t.string   "md5_sum"
    t.string   "content_type"
  end

  add_index "cfs_file_infos", ["content_type"], :name => "index_cfs_file_infos_on_content_type"
  add_index "cfs_file_infos", ["path"], :name => "index_cfs_file_infos_on_path", :unique => true

  create_table "collection_resource_type_joins", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "resource_type_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "collection_resource_type_joins", ["collection_id"], :name => "index_collection_resource_type_joins_on_collection_id"
  add_index "collection_resource_type_joins", ["resource_type_id"], :name => "index_collection_resource_type_joins_on_resource_type_id"

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
    t.text     "notes"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "contact_id"
    t.integer  "preservation_priority_id"
    t.text     "private_description"
    t.text     "notes_html"
    t.text     "description_html"
    t.text     "private_description_html"
    t.string   "uuid"
    t.text     "file_package_summary_html"
  end

  add_index "collections", ["contact_id"], :name => "index_collections_on_contact_id"
  add_index "collections", ["repository_id"], :name => "index_collections_on_repository_id"
  add_index "collections", ["uuid"], :name => "index_collections_on_uuid"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "directories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "collection_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "directories", ["collection_id"], :name => "index_directories_on_collection_id"
  add_index "directories", ["parent_id"], :name => "index_directories_on_parent_id"

  create_table "events", :force => true do |t|
    t.string   "key"
    t.text     "note"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "events", ["eventable_id"], :name => "index_events_on_eventable_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "file_groups", :force => true do |t|
    t.string   "external_file_location"
    t.string   "file_format"
    t.decimal  "total_file_size"
    t.integer  "total_files"
    t.integer  "collection_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "producer_id"
    t.integer  "file_type_id"
    t.text     "summary"
    t.text     "provenance_note"
    t.integer  "root_directory_id"
    t.string   "name"
    t.string   "storage_level"
    t.string   "staged_file_location"
    t.string   "cfs_root"
  end

  add_index "file_groups", ["cfs_root"], :name => "index_file_groups_on_cfs_root", :unique => true
  add_index "file_groups", ["file_type_id"], :name => "index_file_groups_on_file_type_id"
  add_index "file_groups", ["root_directory_id"], :name => "index_file_groups_on_root_directory_id", :unique => true

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

  create_table "producers", :force => true do |t|
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
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "administrator_id"
    t.text     "notes_html"
    t.date     "active_start_date"
    t.date     "active_end_date"
  end

  add_index "producers", ["administrator_id"], :name => "index_production_units_on_administrator_id"

  create_table "related_file_group_joins", :force => true do |t|
    t.integer  "file_group_id"
    t.integer  "related_file_group_id"
    t.string   "note"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "related_file_group_joins", ["file_group_id"], :name => "index_related_file_group_joins_on_file_group_id"
  add_index "related_file_group_joins", ["related_file_group_id"], :name => "index_related_file_group_joins_on_related_file_group_id"

  create_table "repositories", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "notes"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone_number"
    t.string   "email"
    t.integer  "contact_id"
    t.text     "notes_html"
    t.date     "active_start_date"
    t.date     "active_end_date"
  end

  add_index "repositories", ["contact_id"], :name => "index_repositories_on_contact_id"

  create_table "resource_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rights_declarations", :force => true do |t|
    t.integer  "rights_declarable_id"
    t.string   "rights_declarable_type"
    t.string   "rights_basis"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "copyright_jurisdiction"
    t.string   "copyright_statement"
    t.string   "access_restrictions"
  end

  add_index "rights_declarations", ["rights_declarable_id"], :name => "index_rights_declarations_on_rights_declarable_id"

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
