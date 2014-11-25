class RecreateContentTypes < ActiveRecord::Migration
  def change
    create_table :content_types do |t|
      t.string :name, unique: true, default: ''
      t.integer :cfs_file_count, default: 0
      t.decimal :cfs_file_size, default: 0
      t.timestamps
    end
  end
end
