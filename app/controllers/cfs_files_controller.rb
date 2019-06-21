require 'net/http'
#TODO - download/view should probably still use presigned urls when possible (and that might
# happen in the view before the actions are hit) - I'm not
# sure the current implementation is robust, although it does work for the tests.
class CfsFilesController < ApplicationController
  include ActionController::Live

  before_action :require_medusa_user, except: [:show, :download]
  before_action :require_medusa_user_or_basic_auth, only: [:show, :download]
  before_action :find_file, only: [:show, :fits, :download, :view, :events,
                                   :preview_content, :preview_pdf,
                                   :preview_iiif_image, :thumbnail]
  before_action :find_image_helper, only: %i(preview_iiif_image thumbnail)

  helper_method :cfs_file_download_link, :cfs_file_view_link, :cfs_file_content_preview_link

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
    #disposition_string = disposition('attachment', @file)
    filename = URI.encode(@file.name)
    if current_user.present?
      authorize!(:download, @file.file_group)
      @file.with_input_file do |input_file|
        send_file input_file, type: safe_content_type(@file), disposition: 'attachment', filename: filename
      end
    else
      #basic auth
      redirect_to(login_path) unless basic_auth?
      if @file.storage_root.root_type == :filesystem
        @file.with_input_file do |input_file|
          send_file input_file, type: safe_content_type(@file), disposition: 'attachment', filename: filename
        end
      else
        redirect_to(cfs_file_download_link(@file))
      end
    end

  end

  def view
    authorize! :download, @file.file_group
    #disposition_string = disposition('inline', @file)
    filename = URI.encode(@file.name)
    @file.with_input_file do |input_file|
      send_file input_file, type: safe_content_type(@file), disposition: 'inline', filename: filename
    end
  end

  def preview_iiif_image
    authorize! :download, @file.file_group
    response_info = @image_helper.iiif_image_response_info(params)
    send_data response_info[:data], type: response_info[:response_type], disposition: disposition('inline', @file)
  end

  def thumbnail
    authorize! :download, @file.file_group
    render nothing: true, status: 404 unless @image_helper.respond_to?(:thumbnail_data) and @file.exists_on_storage?
    send_data @image_helper.thumbnail_data, type: 'image/jpeg', disposition: 'inline'
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

  def find_image_helper
    @image_helper = Preview::ImageHelper.new(@file)
  end

  #In this and cfs_file_view_link if possible we give a direct link to the content,
  # otherwise we direct through a controller action to get it. The difference in our
  # case is storage in S3 versus storage on the filesystem
  def cfs_file_download_link(cfs_file)
    case cfs_file.storage_root.root_type
    when :filesystem
      download_cfs_file_path(cfs_file)
    when :s3
      cfs_file.storage_root.presigned_get_url(cfs_file.key, response_content_disposition: disposition('attachment', cfs_file),
                                              response_content_type: safe_content_type(cfs_file))
    else
      raise "Unrecognized storage root type #{cfs_file.storage_root.type}"
    end
  end

  def cfs_file_view_link(cfs_file)
    case cfs_file.storage_root.root_type
    when :filesystem
      view_cfs_file_path(cfs_file)
    when :s3
      cfs_file.storage_root.presigned_get_url(cfs_file.key, response_content_disposition: disposition('inline', cfs_file),
                                              response_content_type: safe_content_type(cfs_file))
    else
      raise "Unrecognized storage root type #{cfs_file.storage_root.type}"
    end
  end

  def cfs_file_content_preview_link(cfs_file)
    case cfs_file.storage_root.root_type
    when :filesystem
      preview_content_cfs_file_path(cfs_file)
    when :s3
      cfs_file.storage_root.presigned_get_url(cfs_file.key, response_content_disposition: disposition('inline', cfs_file),
                                              response_content_type: safe_content_type(cfs_file))
    else
      raise "Unrecognized storage root type #{cfs_file.storage_root.type}"
    end
  end

  #note that the way send_file works means that it will automatically append _another_ filename after this string
  # I can't find a way to get it to behave nicely, but it seems to work without harm to do it this way for now.
  # It really expects disposition to just be attachment or inline, but there is no way that I can find to set
  # the utf-8 version of the filename without doing this.
  # When this is used with S3 for presigned urls I expect it'll be okay as is.
  # TODO - still problematic
  # https://aws-medusa-alb.library.illinois.edu/cfs_files/9319280 has a space in the filename and a user had difficulty with
  # it. The current code seems to work properly in Chrome/Firefox/Safari, so I'm going to go with it for now
  # and fix up the filesystem type stuff that goes through Rails instead of AWS presigned links to do the same.
  def disposition(type, cfs_file)
    return %Q(#{type}; filename="#{URI.encode(cfs_file.name)}")
    # if browser.chrome? or browser.safari?
    #   %Q(#{type}; filename="#{cfs_file.name}"; filename*=utf-8''#{URI.encode(cfs_file.name)})
    # elsif browser.ie? or browser.edge?
    #   %Q(#{type}; filename="#{cfs_file.name}"; filename*=utf-8''#{URI.encode(cfs_file.name)})
    # elsif browser.firefox?
    #   %Q(#{type}; filename="#{cfs_file.name}")
    # else
    #   %Q(#{type}; filename="#{cfs_file.name}"; filename*=utf-8''#{URI.encode(cfs_file.name)}")
    # end
  end

  def safe_content_type(cfs_file)
    cfs_file.content_type_name || 'application/octet-stream'
  end

end
