class CfsFilesController < ApplicationController

  before_filter :require_logged_in
  before_filter :find_file, :only => [:show, :create_fits_xml, :fits_xml]

  def show
    @file_group = @file.file_group
  end

  def create_fits_xml
    authorize! :create_cfs_fits, @file.file_group
    @file.ensure_fits_xml
    redirect_to @file.cfs_directory
  end

  def fits_xml
    if @file.fits_xml.present?
      render :xml => @file.fits_xml
    else
      render :text => "Fits XML not present for cfs file #{@file.relative_path}"
    end
  end

  protected

  def find_file
    @file = CfsFile.find(params[:id])
  end

end