class ContentTypesController < ApplicationController
  before_action :require_logged_in

  def cfs_files
    @content_type = ContentType.find(params[:id])
    @cfs_files = @content_type.cfs_files.order('name asc').page(params[:page]).per_page(params[:per_page] || 25)
  end

end
