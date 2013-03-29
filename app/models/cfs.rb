require 'rest_client'
require 'singleton'
require 'pathname'

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
    return unless File.file?(file_path)
    self.create_fits_for(url_path, file_path)
  end

  def ensure_fits_for_tree(url_path)
    file_path = self.file_path_for(url_path)
    #find all files under the path and run fits on those that need it
    Rails.logger.error("Ensuring FITS for tree")
    (Dir[File.join(file_path, '**', '*')] + Dir[File.join(file_path, '**', '.*')]).each do |entry|
      next unless File.file?(entry)
      path = url_path_for(entry)
      Rails.logger.error "Scheduling FITS url:#{path} file: #{entry}"
      self.ensure_fits_for(path)
    end
  end

  def file_path_for(url_path)
    File.join(self.root, url_path)
  end

  def url_path_for(file_path)
    Pathname.new(file_path).relative_path_from(Pathname.new(self.root)).to_s
  end

  def fits_xml(file_path)
    file_path = file_path.gsub(/^\/+/, '')
    RestClient.get("http://localhost:4567/fits/file/#{file_path}")
  end

  protected

  def create_fits_for(url_path, file_path)
    CfsFileInfo.create(:path => url_path, :fits_xml => fits_xml(file_path))
  end

end