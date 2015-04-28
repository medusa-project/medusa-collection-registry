require 'net/http'
class CfsFilesController < ApplicationController

  PUBLIC_ACTIONS = [:public, :public_view, :public_download, :public_preview_image, :public_preview_iiif_image]

  before_action :public_view_enabled?, only: PUBLIC_ACTIONS
  before_action :require_logged_in, except: [:show] + PUBLIC_ACTIONS
  before_action :require_logged_in_or_basic_auth, only: [:show]
  before_action :find_file, only: [:show, :create_fits_xml, :fits, :download, :view,
                                   :preview_image, :preview_video, :fixity_check, :events, :preview_iiif_image] + PUBLIC_ACTIONS
  before_action :require_public_file, only: PUBLIC_ACTIONS
  layout 'public', only: [:public]

  cattr_accessor :mime_type_viewers, :extension_viewers
  helper_method :is_iiif_compatible?

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
    redirect_to unauthorized_path unless @file.public?
    @directory = @file.cfs_directory
    @file_group = @file.file_group
    @collection = @file_group.collection
    @public_object = @file
    @preview_viewer_type = find_preview_viewer_type(@file)
  end

  def create_fits_xml
    authorize! :create_cfs_fits, @file.file_group
    @file.ensure_fits_xml
    redirect_to :back
  end

  def fits
    if @file.fits_xml.present?
      render xml: @file.fits_xml
    else
      render text: "Fits XML not present for cfs file #{@file.relative_path}"
    end
  end

  def fixity_check
    @file_group = @file.file_group
    authorize! :update, @file_group
    @file.events.create!(key: 'fixity_check_run', cascadable: false, actor_email: current_user.email, note: '')
    current_md5 = @file.file_system_md5_sum
    if current_md5 == @file.md5_sum
      flash[:notice] = 'Fixity is confirmed'
      @file.events.create!(key: 'fixity_result', cascadable: false, actor_email: current_user.email, note: 'OK')
    else
      flash[:notice] = "MD5 has changed. Stored: #{@file.md5_sum} Current: #{current_md5}"
      @file.events.create!(key: 'fixity_result', cascadable: true, actor_email: current_user.email, note: 'FAILED')
    end
    redirect_to @file
  end

  def events
    @eventable = @file
    @events = @file.events
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
    common_image_preview
  end

  def public_preview_iiif_image
    common_preview_iiif_image
  end

  def preview_iiif_image
    authorize! :download, @file.file_group
    common_preview_iiif_image
  end

  def preview_video
    authorize! :download, @file.file_group
    send_file @file.absolute_path, type: safe_content_type(@file), disposition: 'inline', filename: @file.name
  end

  protected

  def find_file
    @file = CfsFile.find(params[:id])
    @breadcrumbable = @file
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

  def common_preview_iiif_image
    if params[:iiif_parameters] == 'info' and params[:format] == 'json'
      common_preview_iiif_image_json
    else
      common_preview_iiif_image_jpeg
    end
  end

  def common_preview_iiif_image_json
    image_server_url = iiif_info_json_url(@file)
    response_type = 'application/json'
    json = Net::HTTP.get(URI.parse(image_server_url))
    send_data fix_json_id(json, @file), type: response_type, disposition: 'inline'
  end

  #The IIIF server returns @id in the JSON with _it's_ url information, but for seadragon to work properly
  #proxying through this app we need it to refer back to our medusa URL. This fixes that.
  def fix_json_id(json, file)
    parsed_json = JSON.parse(json)
    parsed_json['@id'] = "/cfs_files/#{file.id}/preview_iiif_image"
    parsed_json.to_json
  end

  def common_preview_iiif_image_jpeg
    image_server_url = iiif_url(@file, params[:iiif_parameters], params[:format])
    response_type = 'image/jpeg'
    image = Net::HTTP.get(URI.parse(image_server_url))
    send_data image, type: response_type, disposition: 'inline'
  end

  def is_iiif_compatible?(file)
    return false if image_server_config['disabled'].present?
    result = Net::HTTP.get_response(URI.parse(iiif_info_json_url(file)))
    result.code == '200' && result.body.index('http://iiif.io/api/image/2/level2.json')
  rescue Exception => e
    Rails.logger.error "Problem determining iiif compatibility for cfs file: #{file.id}.\n #{e}."
    return false
  end

  def iiif_url(file, iiif_parameters, format)
    "#{iiif_base_url(file)}/#{iiif_parameters}.#{format}"
  end

  def iiif_info_json_url(file)
    "#{iiif_base_url(file)}/info.json"
  end

  def iiif_base_url(file)
    image_server_base_url = "http://#{image_server_config['host'] || 'localhost'}:#{image_server_config['port'] || 3000}/#{image_server_config['root']}"
    "#{image_server_base_url}/#{file.relative_path.gsub(' ', '%20')}"
  end

  def require_public_file
    redirect_to unauthorized_path unless @file.public?
  end

  def image_server_config
    MedusaCollectionRegistry::Application.medusa_config['loris']
  end

end
