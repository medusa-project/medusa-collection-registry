require 'net/http'
class CfsFilesController < ApplicationController


  before_action :require_medusa_user, except: [:show]
  before_action :require_medusa_user_or_basic_auth, only: [:show]
  before_action :find_file, only: [:show, :create_fits_xml, :fits, :download, :view,
                                   :preview_image, :preview_video, :fixity_check, :events, :preview_iiif_image]

  helper_method :is_iiif_compatible?

  def show
    @file_group = @file.file_group
    @directory = @file.cfs_directory
    @preview_viewer_type = Preview::Resolver.instance.find_preview_viewer_type(@file)
    @file_format_test = @file.file_format_test
    respond_to do |format|
      format.html
      format.json
    end
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

  def preview_image
    authorize! :download, @file.file_group
    common_image_preview
  end

  def preview_iiif_image
    authorize! :download, @file.file_group
    common_preview_iiif_image
  end

  def preview_video
    authorize! :download, @file.file_group
    send_file @file.absolute_path, type: safe_content_type(@file), disposition: 'inline', filename: @file.name
  end

  def random
    redirect_to CfsFile.random
  end

  protected

  def find_file
    @file = CfsFile.find(params[:id])
    @breadcrumbable = @file
  end


  def safe_content_type(cfs_file)
    cfs_file.content_type_name || 'application/octet-stream'
  end

  def common_image_preview
    image = VIPS::Image.new(@file.absolute_path)
    width = image.x_size
    height = image.y_size
    if width > 300 or height > 300
      factor = ([height, width].max / 300.0).ceil
      image = image.shrink(factor)
    end
    send_data image.jpeg.to_memory, type: 'image/jpeg', disposition: 'inline'
  rescue
    send_data 'Unable to process', type: 'text/plain', disposition: 'inline'
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

  #The IIIF server returns @id in the JSON with _its_ url information, but for seadragon to work properly
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
    "#{image_server_base_url}/#{CGI.escape(file.relative_path)}"
  end

  def image_server_config
    Settings.iiif.to_h.stringify_keys
  end

end
