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
    file_info = CfsFileInfo.find_by_path(url_path)
    return if file_info and file_info.fits_xml
    return unless File.file?(file_path)
    create_fits_for(url_path, file_path)
  end

  def ensure_fits_for_tree(url_path)
    file_path = file_path_for(url_path)
    #find all files under the path and run fits on those that need it
    (Dir[File.join(file_path, '**', '*')] + Dir[File.join(file_path, '**', '.*')]).each do |entry|
      next unless File.file?(entry)
      path = url_path_for(entry)
      Cfs.delay.ensure_fits_for(path)
    end
  end

  def ensure_basic_assessment_for(url_path)
    file_path = file_path_for(url_path)
    file_info = CfsFileInfo.find_by_path(url_path)
    return if file_info and file_info.size and file_info.content_type and file_info.md5_sum
    return unless File.file?(file_path)
    create_basic_assessment_for(url_path, file_path)
  end

  def ensure_basic_assessment_for_tree(url_path)
    file_path = file_path_for(url_path)
    (Dir[File.join(file_path, '**', '*')] + Dir[File.join(file_path, '**', '.*')]).each do |entry|
      next unless File.file?(entry)
      path = url_path_for(entry)
      Cfs.delay.ensure_basic_assessment_for(path)
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
    file_info = CfsFileInfo.find_or_create_by_path(url_path)
    file_info.update_attributes!(:fits_xml => fits_xml(file_path))
  end

  def create_basic_assessment_for(url_path, file_path)
    file_info = CfsFileInfo.find_or_create_by_path(url_path)
    file_info.size = File.size(file_path)
    file_info.content_type = FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(file_path) rescue 'application/octet-stream'
    file_info.md5_sum = Digest::MD5.file(file_path).to_s
    file_info.save!
  end

end