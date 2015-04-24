class ContentTypesController < ApplicationController
  before_action :require_logged_in

  def cfs_files
    @content_type = ContentType.find(params[:id])
    @cfs_files = @content_type.cfs_files.order('name asc').page(params[:page]).per_page(params[:per_page] || 25)
  end

  def fits_batch
    @content_type = ContentType.find(params[:id])
    authorize! :create, ContentType
    if Job::FitsContentTypeBatch.create_for(current_user, @content_type)
      flash[:notice] = "FITS batch scheduled for mime type '#{@content_type.name}'"
    else
      flash[:notice] = "There is already a FITS batch scheduled for mime type '#{@content_type.name}'"
    end
    redirect_to :back
  end

end
