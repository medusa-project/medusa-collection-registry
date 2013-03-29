class CreateCfsFileInfos < ActiveRecord::Migration
  def change
    create_table :cfs_file_infos do |t|
      t.string :path
      t.text :fits_xml

      t.timestamps
    end
    add_index :cfs_file_infos, :path, :unique => true
  end
end
