class CfsFilesController < ApplicationController

  before_filter :require_logged_in
  before_filter :find_file, :only => [:show, :create_fits_xml, :fits_xml, :download, :view,
                                      :preview_image]

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
    send_file @file.absolute_path, type: @file.content_type, disposition: 'inline', filename: @file.name
  end

  protected

  def find_file
    @file = CfsFile.find(params[:id])
  end

  #return a symbol that will be used to select the right viewer
  def find_preview_viewer_type(cfs_file)
    find_previewer_viewer_type_from_mime_type(cfs_file) ||
        find_previewer_viewer_type_from_extension(cfs_file)
  end

  #ultimately do this in config
  def find_previewer_viewer_type_from_mime_type(cfs_file)
    nil
  end

  #ultimately do this in config
  def find_previewer_viewer_type_from_extension(cfs_file)
    case (File.extname(cfs_file.name).sub(/^\./, ''))
      when 'tiff', 'jpg'
        :image
      else
        nil
    end
  end

end