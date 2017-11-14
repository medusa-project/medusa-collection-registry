class Downloader::FileListHandler < Downloader::AbstractHandler

  def export_request_message(cfs_file_list)
    export_request_message_template.tap do |h|
      h[:client_id] = "file_list_#{request.id}"
      #h[:zip_name] = 'medusa_files'
      h[:targets] = cfs_file_list.collect do |cfs_file|
        path = cfs_file.relative_path
        Hash.new.tap do |target|
          target[:type] = 'file'
          target[:path] = path
          target[:zip_path] = File.dirname(path)
        end
      end
    end
  end

  def export_complete_text
    <<TEXT
    Your download for the files:

    #{file_list_text}

    is ready. This link should be valid for at least 14 days.
TEXT
  end

  def export_error_text
    <<TEXT
    There has been an error for your download of the files:

    #{file_list_text}
TEXT
  end

  def export_admin_error_text
    <<TEXT
  There has been an error for the download of the files: 
  #{file_list_text}

  Information:

  #{self.inspect}
TEXT
  end

  protected

  def file_list_text
    file_list = cfs_files.limit(25).collect {|file| file.relative_path}
    file_list << '...' if cfs_files.count > 25
    file_list.join('\n')
  end

  def cfs_files
    CfsFile.where(id: parameters[:cfs_file_ids])
  end

end