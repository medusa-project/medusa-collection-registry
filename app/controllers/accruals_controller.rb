class AccrualsController < ApplicationController

  def update_display
    directory = CfsDirectory.find(params[:cfs_directory_id])
    authorize! :accrue, directory
    @accrual = Accrual.new(cfs_directory: directory, staging_path: params[:staging_path]).decorate
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      #TODO redirect appropriately
    end
  end

end