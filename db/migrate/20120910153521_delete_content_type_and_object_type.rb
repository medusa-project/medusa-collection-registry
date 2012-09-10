class DeleteContentTypeAndObjectType < ActiveRecord::Migration
  def up
    drop_table :collection_object_type_joins
    drop_table :object_types
    drop_table :content_types
  end

  def down
    create_table "content_types", :force => true do |t|
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
    create_table "object_types", :force => true do |t|
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
    create_table "collection_object_type_joins", :force => true do |t|
      t.integer  "collection_id"
      t.integer  "object_type_id"
      t.datetime "created_at",     :null => false
      t.datetime "updated_at",     :null => false
    end

    add_index "collection_object_type_joins", ["collection_id"], :name => "index_collection_object_type_joins_on_collection_id"
    add_index "collection_object_type_joins", ["object_type_id"], :name => "index_collection_object_type_joins_on_object_type_id"
  end
end
