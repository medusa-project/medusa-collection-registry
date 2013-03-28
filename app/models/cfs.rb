require 'rest_client'
require 'singleton'

class Cfs < Object
  include Singleton

  attr_accessor :root, :fits_home, :configured

  def initialize
    config = MedusaRails3::Application.medusa_config['cfs']
    self.root = config['root']
    self.fits_home = config['fits_home']
  end

  def configure(config)
    unless self.configured
      self.root = config['root'].freeze
      self.fits_home = config['fits_home'].freeze
      self.configured = true
    end
  end

  def ensure_fits_for(url_path)
    file_path = self.file_path_for(url_path)
    return if CfsFileInfo.find_by_path(url_path)
    raise RuntimeError, 'File not found for FITS' unless File.file?(file_path)
    CfsFileInfo.create(:path => url_path, :fits_xml => fits_xml(file_path))
  end

  def file_path_for(url_path)
    File.join(self.root, url_path)
  end

  def fits_xml(file_path)
    file_path = file_path.gsub(/^\/+/, '')
    RestClient.get("http://localhost:4567/fits/file/#{file_path}")
  end

end