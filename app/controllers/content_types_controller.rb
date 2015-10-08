class ContentTypesController < ApplicationController
  before_action :require_logged_in
  before_action :find_content_type

  def cfs_files
    @repository_id = params[:repository_id]
    @cfs_files = if @repository_id
                   @content_type.cfs_files.
                       joins(cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}).
                       where('collections.repository_id = ?', @repository_id).order('cfs_files.name asc').page(params[:page]).per_page(params[:per_page] || 25)
                 else
                   @content_type.cfs_files.order('name asc').page(params[:page]).per_page(params[:per_page] || 25)
                 end
  end

  def fits_batch
    authorize! :create, ContentType
    if Job::FitsContentTypeBatch.create_for(current_user, @content_type)
      flash[:notice] = "FITS batch scheduled for mime type '#{@content_type.name}'"
    else
      flash[:notice] = "There is already a FITS batch scheduled for mime type '#{@content_type.name}'"
    end
    redirect_to :back
  end

  def random_cfs_file
    redirect_to @content_type.random_cfs_file
  end

  protected

  def find_content_type
    @content_type = ContentType.find(params[:id])
  end

end
