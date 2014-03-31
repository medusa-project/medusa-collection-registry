class DeleteCfsFileInfos < ActiveRecord::Migration
  def up
    RedFlag.where(:red_flaggable_type => 'CfsFileInfo').each do |red_flag|
      red_flag.destroy
    end
    drop_table :cfs_file_infos
  end

  def down
    create_table "cfs_file_infos" do |t|
      t.string "path"
      t.text "fits_xml"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.decimal "size"
      t.string "md5_sum"
      t.string "content_type"
    end
    add_index "cfs_file_infos", ["content_type"], name: "index_cfs_file_infos_on_content_type", using: :btree
    add_index "cfs_file_infos", ["path"], name: "index_cfs_file_infos_on_path", unique: true, using: :btree
  end

end
