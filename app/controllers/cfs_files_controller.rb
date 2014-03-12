class CfsFilesController < ApplicationController

  before_filter :require_logged_in

  def show
    @file = CfsFile.find(params[:id])
    @file_group = @file.file_group
  end
end