class Downloader::DirectoryHandler < Downloader::AbstractHandler

  def cfs_directory
    CfsDirectory.find(parameters[:cfs_directory_id])
  end

  def export_request_message(recursive: false)
    export_request_message_template.tap do |h|
      h[:zip_name] = File.basename(cfs_directory.path)
      h[:client_id] = "directory_#{request.id}"
      Hash.new.tap do |target|
        h[:targets] = [target]
        target[:recursive] = recursive
        target[:type] = 'directory'
        target[:path] = cfs_directory.relative_path
        target[:zip_path] = ''
      end
    end
  end

  def handle_error(response)
    DownloaderMailer.directory_error(cfs_directory, email, response).deliver_now
    DownloaderMailer.directory_error_admin(cfs_directory, self, response).deliver_now
  end

  def handle_request_completed(response)
    DownloaderMailer.directory_complete(cfs_directory, email, response).deliver_now
  end

end