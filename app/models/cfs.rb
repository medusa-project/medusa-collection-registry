require 'rest_client'
require 'pathname'

module Cfs

  module_function

  def config
    MedusaRails3::Application.medusa_config['cfs']
  end

  def root
    config['root']
  end

  def fits_home
    config['fits_home']
  end

  def ensure_fits_for(url_path)
    file_path = file_path_for(url_path)
    return if CfsFileInfo.find_by_path(url_path)
    return unless File.file?(file_path)
    create_fits_for(url_path, file_path)
  end

  def ensure_fits_for_tree(url_path)
    file_path = file_path_for(url_path)
    #find all files under the path and run fits on those that need it
    Rails.logger.error("Ensuring FITS for tree")
    (Dir[File.join(file_path, '**', '*')] + Dir[File.join(file_path, '**', '.*')]).each do |entry|
      next unless File.file?(entry)
      path = url_path_for(entry)
      Rails.logger.error "Scheduling FITS url:#{path} file: #{entry}"
      Cfs.delay.ensure_fits_for(path)
    end
  end

  def file_path_for(url_path)
    File.join(root, url_path)
  end

  def url_path_for(file_path)
    Pathname.new(file_path).relative_path_from(Pathname.new(root)).to_s
  end

  def fits_xml(file_path)
    file_path = file_path.gsub(/^\/+/, '')
    RestClient.get("http://localhost:4567/fits/file/#{file_path}")
  end

  def create_fits_for(url_path, file_path)
    CfsFileInfo.create(:path => url_path, :fits_xml => fits_xml(file_path))
  end

end