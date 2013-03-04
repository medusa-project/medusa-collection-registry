require 'singleton'
require 'net/http'

class FitsService < Object
  include Singleton

  attr_accessor :service_url, :configured

  def initialize(args = {})
    self.configured = false
  end

  def configure(config_file)
    config = YAML.load_file(config_file)[Rails.env]
    self.service_url = config['service_url']
    self.configured = true
  end

  def get_fits_for(url, user = nil, password = nil)
    make_request('/getfits', {:url => url}, user, password)
  end

  def get_premis_for(url, user = nil, password = nil)
    make_request('/getpremis', {:url => url}, user, password)
  end

  def get_premis_with_local_id_for(url, local_id, user = nil, password = nil)
    make_request("/getpremis/#{local_id}", {:url => url}, user, password)
  end

  protected

  def make_request(path, request_params, user = nil, password = nil)
    raise RuntimeError, "FitsService not configured. Please call FitsService.instance.configure(config_file)." unless self.configured
    uri = URI.parse(self.service_url)
    uri.path = uri.path + path
    uri.query = request_params.collect {|k, v| "#{k}=#{URI.encode(v)}"}.join('&')
    #our servers may have self-signed certs
    agent = Mechanize.new do |a|
      a.verify_mode = OpenSSL::SSL::VERIFY_NONE
      if user and password
        a.basic_auth(user, password)
      end
    end
    page = agent.get(uri.to_s)
    return page.content
  end

end