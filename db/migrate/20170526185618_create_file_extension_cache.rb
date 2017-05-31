class CreateFileExtensionCache < ActiveRecord::Migration[5.0]
  def change
    create_table :cache_file_extension_stats_by_collection, id: false do |t|
      t.integer :collection_id, index: true
      t.integer :file_extension_id
      t.string :extension
      t.integer :file_count
      t.decimal :file_size
    end
    add_index :cache_file_extension_stats_by_collection, :file_extension_id, name: 'index_cache_file_extension_stats_by_collection_fe_id'
  end
end
