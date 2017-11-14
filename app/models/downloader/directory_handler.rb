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

  def export_complete_text
    <<TEXT
  Your download for the directory:

  #{cfs_directory.relative_path}

  is ready. This link should be valid for at least 14 days.
TEXT
  end

  def export_error_text
    "There has been an error for your download for the directory: #{cfs_directory.relative_path}"
  end

  def export_admin_error_text
    <<TEXT
  There has been an error for the download of the directory:

  #{cfs_directory.relative_path}

  Information:

  #{self.inspect}
TEXT
  end

end