class Downloader::AbstractHandler < Object

  attr_accessor :request

  def initialize(request)
    self.request = request
  end

  def email
    request.email
  end

end