class Downloader::FileListHandler < Downloader::AbstractHandler

  def export_request_message(cfs_file_list)
    export_request_message_template.tap do |h|
      h[:client_id] = "file_list_#{request.id}"
      h[:zip_name] = 'files'
      h[:targets] = cfs_file_list.collect do |cfs_file|
        path = cfs_file.relative_path
        Hash.new.tap do |target|
          target[:type] = 'file'
          target[:path] = path
          target[:zip_path] = File.dirname(path).gsub('/', '|')
        end
      end
    end
  end

  def handle_error(response)
    DownloaderMailer.file_list_error(cfs_files, email, response).deliver_now
    DownloaderMailer.file_list_error_admin(cfs_files, response).deliver_now
  end

  def handle_request_completed(response)
    DownloaderMailer.file_list_complete(cfs_files, email, response).deliver_now
  end

  protected

  def cfs_files
    CfsFile.where(id: parameters[:cfs_file_ids])
  end

end