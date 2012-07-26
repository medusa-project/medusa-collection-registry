class CreateFileGroups < ActiveRecord::Migration
  def change
    create_table :file_groups do |t|
      t.string :file_location
      t.string :file_format
      t.decimal :total_file_size
      t.integer :total_files
      t.integer :collection_id, :index => true

      t.timestamps
    end
  end
end
