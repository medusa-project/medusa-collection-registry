class CfsFilesController < ApplicationController

  before_filter :require_logged_in
  before_filter :find_file, :only => [:show, :create_fits_xml, :fits_xml, :download, :view,
                                      :preview_image]

  cattr_accessor :mime_type_viewers, :extension_viewers

  def show
    @file_group = @file.file_group
    @preview_viewer_type = find_preview_viewer_type(@file)
  end

  def create_fits_xml
    authorize! :create_cfs_fits, @file.file_group
    @file.ensure_fits_xml
    redirect_to :back
  end

  def fits_xml
    if @file.fits_xml.present?
      render :xml => @file.fits_xml
    else
      render :text => "Fits XML not present for cfs file #{@file.relative_path}"
    end
  end

  def download
    authorize! :download, @file.file_group
    send_file @file.absolute_path, type: @file.content_type, disposition: 'attachment', filename: @file.name
  end

  def view
    authorize! :download, @file.file_group
    send_file @file.absolute_path, type: @file.content_type, disposition: 'inline', filename: @file.name
  end

  def preview_image
    authorize! :download, @file.file_group
    image = MiniMagick::Image.read(StringIO.new(File.open(@file.absolute_path, 'rb') {|f| f.read}))
    image.format 'jpg'
    image.resize '300x300>'
    send_data image.to_blob, type: 'image/jpeg', disposition: 'inline'
  end

  protected

  def find_file
    @file = CfsFile.find(params[:id])
  end

  #return a symbol that will be used to select the right viewer
  def find_preview_viewer_type(cfs_file)
    self.class.ensure_viewer_hashes
    self.class.mime_type_viewers[cfs_file.content_type] ||
        self.class.extension_viewers[File.extname(cfs_file.name).sub(/^\./, '')] ||
        :none
  end

  def self.ensure_viewer_hashes
    return if self.mime_type_viewers.present? and self.extension_viewers.present?
    viewer_hash = YAML.load_file(File.join(Rails.root, 'config', 'cfs_file_viewers.yaml'))
    self.mime_type_viewers = invert_hash_of_arrays(viewer_hash['mime_types'])
    self.extension_viewers = invert_hash_of_arrays(viewer_hash['extensions'])
  end

  def self.invert_hash_of_arrays(hash_of_arrays)
    Hash.new.tap do |h|
      hash_of_arrays.each do |key, values|
        values.each {|value| h[value] = key.to_sym}
      end
    end
  end

end