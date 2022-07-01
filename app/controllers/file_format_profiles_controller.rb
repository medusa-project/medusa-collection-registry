class FileFormatProfilesController < ApplicationController

  before_action :require_medusa_user, except: [:index, :show]
  before_action :find_file_format_profile, only: [:show, :edit, :update, :destroy, :clone]

  def index
    @file_format_profiles = FileFormatProfile.order(:name)
  end

  def show
    @file_formats = @file_format_profile.file_formats
  end

  def edit
    authorize! :update, @file_format_profile
  end

  def update
    authorize! :update, @file_format_profile
    if @file_format_profile.update(allowed_params)
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

  def clone
    authorize! :create, FileFormatProfile
    @cloned_file_format_profile = @file_format_profile.create_clone
    redirect_to edit_file_format_profile_path(@cloned_file_format_profile)
  end

  def destroy
    authorize! :destroy, @file_format_profile
    if @file_format_profile.destroy
      redirect_to file_format_profiles_path
    else
      redirect_back alert: 'Unable to destroy this rendering profile', fallback_location: file_format_profiles_path
    end
  end

  protected

  def find_file_format_profile
    @file_format_profile = FileFormatProfile.find(params[:id])
  end

  def allowed_params
    params[:file_format_profile].permit(:name, :status, :software, :software_version, :os_environment, :os_version, :notes, file_format_ids: [],
                                        content_type_ids: [], file_extension_ids: [])
  end

end
