class FileFormatProfilesController < ApplicationController
  before_action :require_logged_in
  before_action :find_file_format_profile, only: [:show, :edit, :update, :destroy]

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

  def update
    authorize! :update, @file_format_profile
    if @file_format_profile.update_attributes(allowed_params)
      redirect_to @file_format_profile
    else
      render 'edit'
    end
  end

  def new
    authorize! :create, FileFormatProfile
    @file_format_profile = FileFormatProfile.new
  end

  def create
    authorize! :create, FileFormatProfile
    @file_format_profile = FileFormatProfile.new(allowed_params)
    if @file_format_profile.save
      redirect_to @file_format_profile
    else
      render 'new'
    end
  end

  def destroy
    authorize! :destroy, @file_format_profile
    if @file_format_profile.destroy
      redirect_to file_format_profiles_path
    else
      redirect_to :back, alert: 'Unable to destroy this file format profile'
    end
  end

  protected

  def find_file_format_profile
    @file_format_profile = FileFormatProfile.find(params[:id])
  end

  def allowed_params
    params[:file_format_profile].permit(:name, :software, :software_version, :os_environment, :os_version, :notes,
                                        content_type_ids: [], file_extension_ids: [])
  end

end