class CfsFilesController < ApplicationController

  before_filter :require_logged_in, except: [:show, :public, :public_view, :public_download, :public_preview_image]
  before_filter :require_logged_in_or_basic_auth, only: [:show]
  before_filter :find_file, only: [:show, :public, :create_fits_xml, :fits_xml,
                                   :download, :view, :public_download, :public_view,
                                   :preview_image, :public_preview_image]
  before_filter :require_public_file, only: [:public, :public_download, :public_view, :public_preview_image]
  layout 'public', only: [:public]

  cattr_accessor :mime_type_viewers, :extension_viewers

  def show
    @file_group = @file.file_group
    @directory = @file.cfs_directory
    @preview_viewer_type = find_preview_viewer_type(@file)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def public
    @file_group = @file.file_group
    @directory = @file.cfs_directory
    @preview_viewer_type = find_preview_viewer_type(@file)
  end

  def create_fits_xml
    authorize! :create_cfs_fits, @file.file_group
    @file.ensure_fits_xml
    redirect_to :back
  end

  def fits_xml
    if @file.fits_xml.present?
      render xml: @file.fits_xml
    else
      render text: "Fits XML not present for cfs file #{@file.relative_path}"
    end
  end

  def download
    authorize! :download, @file.file_group
    send_file @file.absolute_path, type: safe_content_type(@file), disposition: 'attachment', filename: @file.name
  end

  def view
    authorize! :download, @file.file_group
    send_file @file.absolute_path, type: safe_content_type(@file), disposition: 'inline', filename: @file.name
  end

  def public_download
    send_file @file.absolute_path, type: safe_content_type(@file), disposition: 'attachment', filename: @file.name
  end

  def public_view
    send_file @file.absolute_path, type: safe_content_type(@file), disposition: 'inline', filename: @file.name
  end

  def preview_image
    authorize! :download, @file.file_group
    common_image_preview
  end

  def public_preview_image
    common_preview_image
  end

  protected

  def find_file
    @file = CfsFile.find(params[:id])
  end

  #return a symbol that will be used to select the right viewer
  def find_preview_viewer_type(cfs_file)
    self.class.ensure_viewer_hashes
    self.class.mime_type_viewers[cfs_file.content_type_name] ||
        self.class.extension_viewers[File.extname(cfs_file.name).sub(/^\./, '').downcase] ||
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
        values.each { |value| h[value] = key.to_sym }
      end
    end
  end

  def safe_content_type(cfs_file)
    cfs_file.content_type_name || 'application/octet-stream'
  end

  def common_image_preview
    image = MiniMagick::Image.read(StringIO.new(File.open(@file.absolute_path, 'rb') { |f| f.read }))
    image.format 'jpg'
    image.resize '300x300>'
    send_data image.to_blob, type: 'image/jpeg', disposition: 'inline'
  end

  def require_public_file
    redirect_to unauthorized_path unless @file.public?
  end

end