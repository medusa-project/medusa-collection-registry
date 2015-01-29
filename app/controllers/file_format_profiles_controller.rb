class FileFormatProfilesController < ApplicationController
  before_filter :require_logged_in
  before_filter :find_file_format_profile, only: [:show, :edit]

  def index
    authorize! :read, FileFormatProfile
    @file_format_profiles = FileFormatProfile.order('name asc')
  end

  def show
    authorize! :read, @file_format_profile
  end

  def edit
    authorize! :update, @file_format_profile
  end

  protected

  def find_file_format_profile
    @file_format_profile = FileFormatProfile.find(params[:id])
  end

end