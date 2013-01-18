class BitFilesController < ApplicationController

  skip_before_filter :require_logged_in, :only => :show
  skip_before_filter :authorize, :only => :show

  def show
    @bit_file = BitFile.find(params[:id])
    respond_to do |format|
      format.json
    end
  end

end