class CfsDirectoriesController < ApplicationController

  before_filter :require_logged_in

  def show
    @directory = CfsDirectory.includes(:subdirectories, :cfs_files).find(params[:id])
    @file_group = @directory.owning_file_group
  end
end