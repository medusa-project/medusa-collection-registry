require 'rest_client'
require 'singleton'

class Cfs < Object
  include Singleton

  attr_accessor :root, :fits_home

  def configure(config)
    self.root = config['root']
    self.fits_home = config['fits_home']
  end

  def ensure_fits_for(url_path)
    file_path = Cfs.file_path_for(url_path)
    return if CfsFileInfo.find_by_path(url_path)
    raise RuntimeError, 'File not found for FITS' unless File.file?(file_path)
    CfsFileInfo.create(:path => url_path, :fits_xml => fits_xml(file_path))
  end

  def file_path_for(url_path)
    File.join(self.root, url_path)
  end

  def fits_xml(file_path)
    RestClient.get("http://localhost:4567/fits/file#{file_path}")
  end

end