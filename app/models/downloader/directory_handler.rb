class Downloader::DirectoryHandler < Downloader::AbstractHandler

  def cfs_directory
    CfsDirectory.find(request.parameters[:cfs_directory_id])
  end

  def export_request_message(recursive: false)
    config = Settings.downloader
    Hash.new.tap do |h|
      h[:action] = :export
      h[:client_id] = "directory_#{request.id}"
      h[:return_queue] = config.incoming_queue
      h[:root] = config.root
      h[:zip_name] = File.basename(cfs_directory.path)
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
    CfsMailer.export_error_user(self, response).deliver_now
    CfsMailer.export_error_admin(self, response).deliver_now
  end

  def handle_request_completed(response)
    CfsMailer.export_complete(self, response).deliver_now
  end

end