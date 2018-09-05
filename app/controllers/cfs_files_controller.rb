require 'net/http'
#TODO - download/view should probably still use presigned urls when possible (and that might
# happen in the view before the actions are hit) - I'm not
# sure the current implementation is robust, although it does work for the tests.
class CfsFilesController < ApplicationController
  include ActionController::Live

  before_action :require_medusa_user, except: [:show, :download]
  before_action :require_medusa_user_or_basic_auth, only: [:show, :download]
  before_action :find_file, only: [:show, :create_fits_xml, :fits, :download, :view, :events,
                                   :preview_image, :preview_content, :preview_pdf,
                                   :preview_iiif_image, :thumbnail]
  before_action :find_previewer, only: [:show, :preview_image, :preview_content, :preview_pdf, :preview_iiif_image, :thumbnail]

  def show
    @file_group = @file.file_group
    @directory = @file.cfs_directory
    @file_format_test = @file.file_format_test
    respond_to do |format|
      format.html
      format.json
    end
  end

  def fits
    if @file.fits_xml.present?
      render xml: @file.fits_xml
    else
      render text: "Fits XML not present for cfs file #{@file.relative_path}"
    end
  end

  def events
    @helper = SearchHelper::TableEvent.new(params: params, cascaded_eventable: @file)
    respond_to do |format|
      format.html
      format.json do
        render json: @helper.json_response
      end
    end
  end

  def download
    if current_user.present?
      authorize!(:download, @file.file_group)
    else
      #basic auth
      redirect_to(login_path) unless basic_auth?
    end
    @file.with_input_file do |input_file|
      send_file input_file, type: safe_content_type(@file), disposition: 'attachment', filename: @file.name
    end
  end

  def view
    authorize! :download, @file.file_group
    @file.with_input_file do |input_file|
      send_file input_file, type: safe_content_type(@file), disposition: 'inline', filename: @file.name
    end
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
    render nothing: true, status: 404 unless @previewer.respond_to?(:thumbnail_data) and @file.exists_on_storage?
    send_data @previewer.thumbnail_data, type: 'image/jpeg', disposition: 'inline'
  end

  def preview_content
    authorize! :download, @file.file_group
    @file.with_input_file do |input_file|
      send_file input_file, type: safe_content_type(@file), disposition: 'inline', range: true, buffer_size: 100000
    end
  end

  def preview_pdf
    authorize! :download, @file.file_group
    render layout: nil
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
    @previewer = safe_can?(:download, @file.file_group) ? @file.previewer : Preview::Default.new(@file)
  end

  def safe_content_type(cfs_file)
    cfs_file.content_type_name || 'application/octet-stream'
  end

end
