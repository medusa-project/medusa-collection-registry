class AddParametersToDownloaderRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :downloader_requests, :parameters, :text
    Downloader::Request.find_each do |request|
      request.parameters = {type: 'directory', cfs_directory_id: request.cfs_directory_id}
      request.save!
    end
    remove_column :downloader_requests, :cfs_directory_id
  end
end
