class AccrualsController < ApplicationController

  def update_display
    @accrual = Accrual.new(cfs_directory: CfsDirectory.find(params[:cfs_directory_id]), staging_path: params[:staging_path]).decorate
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      #redirect appropriately
    end
  end

end