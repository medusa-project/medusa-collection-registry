class FileExtensionsController < ApplicationController
  before_action :require_logged_in

  def cfs_files
    @file_extension = FileExtension.find(params[:id])
    @cfs_files = @file_extension.cfs_files.order('name asc').page(params[:page]).per_page(params[:per_page] || 25)
  end

  def fits_batch
    @file_extension = FileExtension.find(params[:id])
    authorize! :create, FileExtension
    if Job::FitsFileExtensionBatch.create_for(current_user, @file_extension)
      flash[:notice] = "FITS batch scheduled for extension '#{@file_extension.extension}'"
    else
      flash[:notice] = "There is already a FITS batch scheduled for extension '#{@file_extension.extension}'"
    end
    redirect_to :back
  end
end