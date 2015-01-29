class CreateFileExtensions < ActiveRecord::Migration
  def change
    create_table :file_extensions do |t|
      t.string :extension, null: false
      t.decimal :cfs_file_size, default: 0
      t.integer :cfs_file_count, default: 0

      t.timestamps null: false
    end
    add_index :file_extensions, :extension, unique: true
  end
end
