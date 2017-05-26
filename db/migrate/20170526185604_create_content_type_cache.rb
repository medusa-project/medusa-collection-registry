class CreateContentTypeCache < ActiveRecord::Migration[5.0]
  def change
    create_table :cache_content_type_stats_by_collection, id: false do |t|
      t.integer :collection_id, index: true
      t.integer :content_type_id, index: true
      t.string :name
      t.integer :file_count
      t.decimal :file_size
    end
  end
end
