class Downloader::Request < ActiveRecord::Base

  belongs_to :cfs_directory

  def self.handle_response(payload)
    raise RuntimeError, "Not Yet Implemented"
    #parse payload
    #find request and action from payload
    #handle that request
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

  def send_request
    raise RuntimeError, "Not Yet Implemented"
    #construct and send message to downloader
  end

end
