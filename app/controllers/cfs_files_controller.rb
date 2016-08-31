require 'net/http'
class CfsFilesController < ApplicationController


  before_action :require_medusa_user, except: [:show]
  before_action :require_medusa_user_or_basic_auth, only: [:show]
  before_action :find_file, only: [:show, :create_fits_xml, :fits, :download, :view, :fixity_check, :events,
                                   :preview_image, :preview_video, :preview_iiif_image, :thumbnail]
  before_action :find_previewer, only: [:show, :preview_image, :preview_video, :preview_iiif_image, :thumbnail]

  def show
    @file_group = @file.file_group
    @directory = @file.cfs_directory
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
    send_data @previewer.default_image_response_info, type: 'image/jpeg', disposition: 'inline'
  end

  def preview_iiif_image
    authorize! :download, @file.file_group
    response_info = @previewer.iiif_image_response_info(params)
    send_data response_info[:data], type: response_info[:response_type], disposition: 'inline'
  end

  def thumbnail
    authorize! :download, @file.file_group
    render nothing: true, status: 404 unless @previewer.respond_to?(:thumbnail_data) and @file.exists_on_filesystem?
    send_data @previewer.thumbnail_data, type: 'image/jpeg', disposition: 'inline'
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

  def find_previewer
    @previewer = Preview::Resolver.instance.find_previewer(@file)
  end

  def safe_content_type(cfs_file)
    cfs_file.content_type_name || 'application/octet-stream'
  end

end
