class CreateBitFiles < ActiveRecord::Migration
  def change
    create_table :bit_files do |t|
      t.integer :directory_id
      t.string :md5sum
      t.string :name
      t.string :dx_name
      t.string :content_type
      t.boolean :dx_ingested, :default => false
      t.integer :size

      t.timestamps
    end
    add_index :bit_files, :directory_id
    add_index :bit_files, :content_type
    add_index :bit_files, :dx_name
    add_index :bit_files, :name
  end
end
