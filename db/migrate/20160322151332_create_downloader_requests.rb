class CreateDownloaderRequests < ActiveRecord::Migration
  def change
    create_table :downloader_requests do |t|
      t.string :email
      t.integer :cfs_directory_id
      t.string :downloader_id, index: true
      t.timestamps null: false
    end
  end
end
