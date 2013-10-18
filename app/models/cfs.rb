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

  def ensure_fits_for(url_path)
    file_path = file_path_for(url_path)
    file_info = CfsFileInfo.find_by_path(url_path)
    return if file_info and file_info.fits_xml
    return unless File.file?(file_path)
    create_fits_for(url_path, file_path)
  end

  def update_fits_for(url_path)
    file_path = file_path_for(url_path)
    return unless File.file?(file_path)
    create_fits_for(url_path, file_path)
  end

  def ensure_fits_for_tree(url_path, parent_job = nil)
    self.each_file_path_in_tree(url_path) do |file_path|
      Delayed::Job.enqueue(Job::FitsFile.new(:path => file_path,
                                             :fits_directory_tree_id => (parent_job.blank? ? nil : parent_job.id)),
                           :priority => 60)
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
    self.each_file_path_in_tree(url_path) do |file_path|
      Cfs.delay(:priority => 40).ensure_basic_assessment_for(file_path)
    end
  end

  #find the file path for each file under url_path and yield to block
  def each_file_path_in_tree(url_path)
    file_path = file_path_for(url_path)
    (Dir[File.join(file_path, '**', '*')] + Dir[File.join(file_path, '**', '.*')]).each do |entry|
      next unless File.file?(entry)
      file_path = url_path_for(entry)
      yield(file_path)
    end
  end

  def file_path_for(url_path)
    File.join(root, url_path)
  end

  def url_path_for(file_path)
    Pathname.new(file_path).relative_path_from(Pathname.new(root)).to_s
  end

  def get_fits_xml(file_path)
    file_path = file_path.gsub(/^\/+/, '')
    resource =  RestClient::Resource.new("http://localhost:4567/fits/file/#{file_path}", :timeout => -1)
    response = resource.get
    return response.body
  end

  def create_fits_for(url_path, file_path)
    file_info = CfsFileInfo.find_or_create_by(path: url_path)
    fits_xml = get_fits_xml(file_path)
    extracted_properties = extract_fits_properties(fits_xml)
    check_red_flags(file_info, fits_xml, extracted_properties)
    file_info.update_attributes!(extracted_properties.merge(:fits_xml => fits_xml))
  end

  def extract_fits_properties(fits_xml)
    doc = Nokogiri::XML::Document.parse(fits_xml)
    Hash.new.tap do |h|
      h[:size] = doc.at_css('fits fileinfo size').text.to_i
      h[:md5_sum] = doc.at_css('fits fileinfo md5checksum').text
      h[:content_type] = doc.at_css('fits identification identity')['mimetype']
    end
  end

  def check_red_flags(file_info, fits_xml, extracted_properties)
    check_content_type_red_flag(file_info, extracted_properties) if file_info.fits_xml
    check_size_red_flag(file_info, extracted_properties)
    check_md5_sum_red_flag(file_info, extracted_properties)
    x = file_info.red_flags(true)
  end

  def check_content_type_red_flag(file_info, extracted_properties)
    unless file_info.content_type == extracted_properties[:content_type]
      file_info.red_flags.create(:message => "Content Type changed. Old: #{file_info.content_type} New: #{extracted_properties[:content_type]}")
    end
  end

  def check_size_red_flag(file_info, extracted_properties)
    unless file_info.size == extracted_properties[:size]
      file_info.red_flags.create(:message => "Size changed. Old: #{file_info.size} New: #{extracted_properties[:size]}")
    end
  end

  def check_md5_sum_red_flag(file_info, extracted_properties)
    unless file_info.md5_sum == extracted_properties[:md5_sum]
      file_info.red_flags.create(:message => "Md5 Sum changed. Old: #{file_info.md5_sum} New: #{extracted_properties[:md5_sum]}")
    end
  end

  def create_basic_assessment_for(url_path, file_path)
    file_info = CfsFileInfo.find_or_create_by(path: url_path)
    file_info.size = File.size(file_path)
    file_info.content_type = FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(file_path) rescue 'application/octet-stream'
    file_info.md5_sum = Digest::MD5.file(file_path).to_s
    file_info.save!
  end

end