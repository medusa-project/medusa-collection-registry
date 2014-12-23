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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141222162152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_system_collection_joins", force: true do |t|
    t.integer  "access_system_id"
    t.integer  "collection_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "access_system_collection_joins", ["access_system_id"], name: "index_access_system_collection_joins_on_access_system_id", using: :btree
  add_index "access_system_collection_joins", ["collection_id"], name: "index_access_system_collection_joins_on_collection_id", using: :btree
  add_index "access_system_collection_joins", ["updated_at"], name: "index_access_system_collection_joins_on_updated_at", using: :btree

  create_table "access_systems", force: true do |t|
    t.string   "name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "service_owner"
    t.string   "application_manager"
  end

  add_index "access_systems", ["updated_at"], name: "index_access_systems_on_updated_at", using: :btree

  create_table "amazon_backups", force: true do |t|
    t.integer  "cfs_directory_id"
    t.integer  "part_count"
    t.date     "date"
    t.text     "archive_ids"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "amazon_backups", ["cfs_directory_id"], name: "index_amazon_backups_on_cfs_directory_id", using: :btree
  add_index "amazon_backups", ["updated_at"], name: "index_amazon_backups_on_updated_at", using: :btree

  create_table "assessments", force: true do |t|
    t.date     "date"
    t.text     "preservation_risks"
    t.text     "notes"
    t.integer  "assessable_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
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

  add_index "assessments", ["assessable_id"], name: "index_assessments_on_collection_id", using: :btree
  add_index "assessments", ["author_id"], name: "index_assessments_on_author_id", using: :btree
  add_index "assessments", ["updated_at"], name: "index_assessments_on_updated_at", using: :btree

  create_table "attachments", force: true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.integer  "author_id"
    t.text     "description"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "attachments", ["updated_at"], name: "index_attachments_on_updated_at", using: :btree

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
    t.boolean  "exists_in_google",           default: false
  end

  add_index "book_tracker_items", ["author"], name: "index_book_tracker_items_on_author", using: :btree
  add_index "book_tracker_items", ["bib_id"], name: "index_book_tracker_items_on_bib_id", using: :btree
  add_index "book_tracker_items", ["date"], name: "index_book_tracker_items_on_date", using: :btree
  add_index "book_tracker_items", ["exists_in_hathitrust"], name: "index_book_tracker_items_on_exists_in_hathitrust", using: :btree
  add_index "book_tracker_items", ["exists_in_internet_archive"], name: "index_book_tracker_items_on_exists_in_internet_archive", using: :btree
  add_index "book_tracker_items", ["ia_identifier"], name: "index_book_tracker_items_on_ia_identifier", using: :btree
  add_index "book_tracker_items", ["obj_id"], name: "index_book_tracker_items_on_obj_id", using: :btree
  add_index "book_tracker_items", ["oclc_number"], name: "index_book_tracker_items_on_oclc_number", using: :btree
  add_index "book_tracker_items", ["title"], name: "index_book_tracker_items_on_title", using: :btree
  add_index "book_tracker_items", ["volume"], name: "index_book_tracker_items_on_volume", using: :btree

  create_table "book_tracker_tasks", force: true do |t|
    t.string   "name"
    t.decimal  "service",          precision: 1, scale: 0
    t.decimal  "status",           precision: 1, scale: 0
    t.float    "percent_complete",                         default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
  end

  create_table "cfs_directories", force: true do |t|
    t.text     "path"
    t.integer  "parent_cfs_directory_id"
    t.integer  "root_cfs_directory_id"
    t.decimal  "tree_size",               default: 0.0
    t.integer  "tree_count",              default: 0
    t.integer  "file_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cfs_directories", ["parent_cfs_directory_id", "path"], name: "index_cfs_directories_on_parent_cfs_directory_id_and_path", unique: true, using: :btree
  add_index "cfs_directories", ["path"], name: "index_cfs_directories_on_path", using: :btree
  add_index "cfs_directories", ["root_cfs_directory_id"], name: "index_cfs_directories_on_root_cfs_directory_id", using: :btree
  add_index "cfs_directories", ["updated_at"], name: "index_cfs_directories_on_updated_at", using: :btree

  create_table "cfs_files", force: true do |t|
    t.integer  "cfs_directory_id"
    t.string   "name"
    t.decimal  "size"
    t.text     "fits_xml"
    t.datetime "mtime"
    t.string   "md5_sum"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "content_type_id"
  end

  add_index "cfs_files", ["cfs_directory_id", "name"], name: "index_cfs_files_on_cfs_directory_id_and_name", unique: true, using: :btree
  add_index "cfs_files", ["content_type_id"], name: "index_cfs_files_on_content_type_id", using: :btree
  add_index "cfs_files", ["mtime"], name: "index_cfs_files_on_mtime", using: :btree
  add_index "cfs_files", ["name"], name: "index_cfs_files_on_name", using: :btree
  add_index "cfs_files", ["size"], name: "index_cfs_files_on_size", using: :btree
  add_index "cfs_files", ["updated_at"], name: "index_cfs_files_on_updated_at", using: :btree

  create_table "collections", force: true do |t|
    t.integer  "repository_id"
    t.string   "title"
    t.boolean  "published"
    t.boolean  "ongoing"
    t.text     "description"
    t.string   "access_url"
    t.text     "notes"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "contact_id"
    t.integer  "preservation_priority_id"
    t.text     "private_description"
    t.text     "notes_html"
    t.text     "description_html"
    t.text     "private_description_html"
    t.string   "external_id"
  end

  add_index "collections", ["contact_id"], name: "index_collections_on_contact_id", using: :btree
  add_index "collections", ["external_id"], name: "index_collections_on_external_id", using: :btree
  add_index "collections", ["repository_id"], name: "index_collections_on_repository_id", using: :btree
  add_index "collections", ["updated_at"], name: "index_collections_on_updated_at", using: :btree

  create_table "content_types", force: true do |t|
    t.string   "name",           default: ""
    t.integer  "cfs_file_count", default: 0
    t.decimal  "cfs_file_size",  default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "events", force: true do |t|
    t.string   "key"
    t.text     "note"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "actor_email"
    t.date     "date"
  end

  add_index "events", ["actor_email"], name: "index_events_on_actor_email", using: :btree
  add_index "events", ["eventable_id"], name: "index_events_on_eventable_id", using: :btree
  add_index "events", ["updated_at"], name: "index_events_on_updated_at", using: :btree

  create_table "file_groups", force: true do |t|
    t.string   "external_file_location"
    t.string   "file_format"
    t.decimal  "total_file_size"
    t.integer  "total_files"
    t.integer  "collection_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "producer_id"
    t.text     "description"
    t.text     "provenance_note"
    t.string   "title"
    t.string   "staged_file_location"
    t.string   "cfs_root"
    t.string   "type"
    t.integer  "package_profile_id"
    t.string   "external_id"
    t.text     "private_description"
    t.string   "access_url"
  end

  add_index "file_groups", ["cfs_root"], name: "index_file_groups_on_cfs_root", unique: true, using: :btree
  add_index "file_groups", ["external_id"], name: "index_file_groups_on_external_id", using: :btree
  add_index "file_groups", ["package_profile_id"], name: "index_file_groups_on_package_profile_id", using: :btree
  add_index "file_groups", ["type"], name: "index_file_groups_on_type", using: :btree
  add_index "file_groups", ["updated_at"], name: "index_file_groups_on_updated_at", using: :btree

  create_table "institutions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "institutions", ["name"], name: "index_institutions_on_name", using: :btree
  add_index "institutions", ["updated_at"], name: "index_institutions_on_updated_at", using: :btree

  create_table "job_amazon_backups", force: true do |t|
    t.integer "amazon_backup_id"
  end

  create_table "job_cfs_directory_export_cleanups", force: true do |t|
    t.string "directory"
  end

  create_table "job_cfs_directory_exports", force: true do |t|
    t.integer "user_id"
    t.integer "cfs_directory_id"
    t.string  "uuid"
    t.boolean "recursive"
  end

  create_table "job_cfs_initial_directory_assessments", force: true do |t|
    t.integer "file_group_id"
    t.integer "cfs_directory_id"
    t.integer "file_count"
  end

  add_index "job_cfs_initial_directory_assessments", ["cfs_directory_id"], name: "index_job_cfs_initial_directory_assessments_on_cfs_directory_id", using: :btree
  add_index "job_cfs_initial_directory_assessments", ["file_group_id"], name: "index_job_cfs_initial_directory_assessments_on_file_group_id", using: :btree

  create_table "job_cfs_initial_file_group_assessments", force: true do |t|
    t.integer "file_group_id"
  end

  add_index "job_cfs_initial_file_group_assessments", ["file_group_id"], name: "index_job_cfs_initial_file_group_assessments_on_file_group_id", using: :btree

  create_table "job_fits_directories", force: true do |t|
    t.integer  "cfs_directory_id"
    t.integer  "file_group_id"
    t.integer  "file_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "job_fits_directories", ["cfs_directory_id"], name: "index_job_fits_directories_on_cfs_directory_id", using: :btree
  add_index "job_fits_directories", ["file_group_id"], name: "index_job_fits_directories_on_file_group_id", using: :btree

  create_table "job_fits_directory_trees", force: true do |t|
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "cfs_directory_id"
    t.integer  "file_group_id"
  end

  add_index "job_fits_directory_trees", ["cfs_directory_id"], name: "index_job_fits_directory_trees_on_cfs_directory_id", using: :btree
  add_index "job_fits_directory_trees", ["file_group_id"], name: "index_job_fits_directory_trees_on_file_group_id", using: :btree

  create_table "job_ingest_staging_deletes", force: true do |t|
    t.integer "external_file_group_id"
    t.integer "user_id"
    t.text    "path"
  end

  add_index "job_ingest_staging_deletes", ["external_file_group_id"], name: "index_job_ingest_staging_deletes_on_external_file_group_id", using: :btree
  add_index "job_ingest_staging_deletes", ["user_id"], name: "index_job_ingest_staging_deletes_on_user_id", using: :btree

  create_table "job_virus_scans", force: true do |t|
    t.integer  "file_group_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "job_virus_scans", ["updated_at"], name: "index_job_virus_scans_on_updated_at", using: :btree

  create_table "medusa_uuids", force: true do |t|
    t.string   "uuid"
    t.integer  "uuidable_id"
    t.string   "uuidable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "medusa_uuids", ["uuid"], name: "index_medusa_uuids_on_uuid", unique: true, using: :btree
  add_index "medusa_uuids", ["uuidable_id", "uuidable_type"], name: "index_medusa_uuids_on_uuidable_id_and_uuidable_type", using: :btree

  create_table "package_profiles", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "package_profiles", ["updated_at"], name: "index_package_profiles_on_updated_at", using: :btree

  create_table "people", force: true do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "people", ["email"], name: "index_people_on_email", using: :btree
  add_index "people", ["updated_at"], name: "index_people_on_updated_at", using: :btree

  create_table "preservation_priorities", force: true do |t|
    t.string   "name"
    t.float    "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "preservation_priorities", ["updated_at"], name: "index_preservation_priorities_on_updated_at", using: :btree

  create_table "producers", force: true do |t|
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
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "administrator_id"
    t.text     "notes_html"
    t.date     "active_start_date"
    t.date     "active_end_date"
  end

  add_index "producers", ["administrator_id"], name: "index_production_units_on_administrator_id", using: :btree
  add_index "producers", ["updated_at"], name: "index_producers_on_updated_at", using: :btree

  create_table "red_flags", force: true do |t|
    t.integer  "red_flaggable_id"
    t.string   "red_flaggable_type"
    t.string   "message"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "notes"
    t.string   "priority"
    t.string   "status"
  end

  add_index "red_flags", ["priority"], name: "index_red_flags_on_priority", using: :btree
  add_index "red_flags", ["red_flaggable_id"], name: "index_red_flags_on_red_flaggable_id", using: :btree
  add_index "red_flags", ["red_flaggable_type"], name: "index_red_flags_on_red_flaggable_type", using: :btree
  add_index "red_flags", ["status"], name: "index_red_flags_on_status", using: :btree
  add_index "red_flags", ["updated_at"], name: "index_red_flags_on_updated_at", using: :btree

  create_table "related_file_group_joins", force: true do |t|
    t.integer  "source_file_group_id"
    t.integer  "target_file_group_id"
    t.string   "note"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "related_file_group_joins", ["source_file_group_id"], name: "index_related_file_group_joins_on_source_file_group_id", using: :btree
  add_index "related_file_group_joins", ["target_file_group_id"], name: "index_related_file_group_joins_on_target_file_group_id", using: :btree
  add_index "related_file_group_joins", ["updated_at"], name: "index_related_file_group_joins_on_updated_at", using: :btree

  create_table "repositories", force: true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "notes"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
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
    t.string   "ldap_admin_domain"
    t.string   "ldap_admin_group"
    t.integer  "institution_id"
  end

  add_index "repositories", ["contact_id"], name: "index_repositories_on_contact_id", using: :btree
  add_index "repositories", ["institution_id"], name: "index_repositories_on_institution_id", using: :btree
  add_index "repositories", ["updated_at"], name: "index_repositories_on_updated_at", using: :btree

  create_table "resource_typeable_resource_type_joins", force: true do |t|
    t.integer  "resource_typeable_id"
    t.integer  "resource_type_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "resource_typeable_type"
  end

  add_index "resource_typeable_resource_type_joins", ["resource_type_id"], name: "index_resource_typeable_resource_type_joins_on_resource_type_id", using: :btree
  add_index "resource_typeable_resource_type_joins", ["resource_typeable_id"], name: "index_resource_typeable_id", using: :btree
  add_index "resource_typeable_resource_type_joins", ["updated_at"], name: "index_resource_typeable_resource_type_joins_on_updated_at", using: :btree

  create_table "resource_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "resource_types", ["updated_at"], name: "index_resource_types_on_updated_at", using: :btree

  create_table "rights_declarations", force: true do |t|
    t.integer  "rights_declarable_id"
    t.string   "rights_declarable_type"
    t.string   "rights_basis"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "copyright_jurisdiction"
    t.string   "copyright_statement"
    t.string   "access_restrictions"
  end

  add_index "rights_declarations", ["rights_declarable_id"], name: "index_rights_declarations_on_rights_declarable_id", using: :btree
  add_index "rights_declarations", ["updated_at"], name: "index_rights_declarations_on_updated_at", using: :btree

  create_table "scheduled_events", force: true do |t|
    t.string   "key"
    t.string   "state"
    t.date     "action_date"
    t.string   "actor_email"
    t.integer  "scheduled_eventable_id"
    t.string   "scheduled_eventable_type"
    t.text     "note"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "scheduled_events", ["actor_email"], name: "index_scheduled_events_on_actor_email", using: :btree
  add_index "scheduled_events", ["key"], name: "index_scheduled_events_on_key", using: :btree
  add_index "scheduled_events", ["scheduled_eventable_id"], name: "index_scheduled_events_on_scheduled_eventable_id", using: :btree
  add_index "scheduled_events", ["scheduled_eventable_type"], name: "index_scheduled_events_on_scheduled_eventable_type", using: :btree
  add_index "scheduled_events", ["updated_at"], name: "index_scheduled_events_on_updated_at", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "storage_media", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "storage_media", ["updated_at"], name: "index_storage_media_on_updated_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "email"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree
  add_index "users", ["updated_at"], name: "index_users_on_updated_at", using: :btree

  create_table "virus_scans", force: true do |t|
    t.integer  "file_group_id"
    t.text     "scan_result"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "virus_scans", ["file_group_id"], name: "index_virus_scans_on_file_group_id", using: :btree
  add_index "virus_scans", ["updated_at"], name: "index_virus_scans_on_updated_at", using: :btree

  create_table "workflow_ingests", force: true do |t|
    t.string   "state"
    t.integer  "external_file_group_id"
    t.integer  "bit_level_file_group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amazon_backup_id"
  end

  add_index "workflow_ingests", ["amazon_backup_id"], name: "index_workflow_ingests_on_amazon_backup_id", using: :btree
  add_index "workflow_ingests", ["bit_level_file_group_id"], name: "index_workflow_ingests_on_bit_level_file_group_id", using: :btree
  add_index "workflow_ingests", ["external_file_group_id"], name: "index_workflow_ingests_on_external_file_group_id", using: :btree
  add_index "workflow_ingests", ["updated_at"], name: "index_workflow_ingests_on_updated_at", using: :btree
  add_index "workflow_ingests", ["user_id"], name: "index_workflow_ingests_on_user_id", using: :btree

end
