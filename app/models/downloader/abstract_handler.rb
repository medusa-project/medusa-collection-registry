class Downloader::AbstractHandler < Object

  attr_accessor :request

  def initialize(request)
    self.request = request
  end

  def parameters
    request.parameters
  end

  def email
    request.email
  end

  def export_request_message_template
    config = Settings.downloader
    Hash.new.tap do |h|
      h[:action] = :export
      h[:return_queue] = config.incoming_queue
      h[:root] = config.root
    end
  end

end