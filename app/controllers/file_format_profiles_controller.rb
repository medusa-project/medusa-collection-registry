class FileFormatProfilesController < ApplicationController
  before_filter :require_logged_in

  def index
    authorize! :read, FileFormatProfile
    @file_format_profiles = FileFormatProfile.order('name asc')
  end

end