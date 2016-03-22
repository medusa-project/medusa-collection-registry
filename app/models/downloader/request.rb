class Downloader::Request < ActiveRecord::Base

  belongs_to :cfs_directory

  def self.handle_response(payload)
    raise RuntimeError, "Not Yet Implemented"
    #parse payload
    #find request and action from payload
    #handle that request
  end

  def self.create_for(cfs_directory, user, recursive: false)
    request = self.create!(cfs_directory: cfs_directory, email: user.email)
    request.send_export_request(recursive: recursive)
  end

  def handle_request_received
    raise RuntimeError, "Not Yet Implemented"
    #store downloader id
  end

  def handle_error
    raise RuntimeError, "Not Yet Implemented"
    #email user with error message
    #email admin with error message
  end

  def handle_request_completed
    raise RuntimeError, "Not Yet Implemented"
    #email user with particulars of download
  end

  def send_export_request(recursive: false)
    AmqpConnector.connector(:downloader).send_message(Application.downloader_config.outgoing_queue, export_request_message(recursive: recursive))
  end

  def export_request_message(recursive: false)
    config = Application.downloader_config
    Hash.new.tap do |h|
      h[:action] = :export
      h[:client_id] = self.id.to_s
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

end
