class FileExtensionsController < ApplicationController
  before_action :require_logged_in

  def cfs_files
    @file_extension = FileExtension.find(params[:id])
    @cfs_files = @file_extension.cfs_files.order('name asc').page(params[:page]).per_page(params[:per_page] || 25)
  end

end