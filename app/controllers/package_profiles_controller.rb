class PackageProfilesController < ApplicationController

  before_filter :require_logged_in, :except => [:index]
  before_filter :find_package_profile, :only => [:show, :edit, :update, :destroy]

  def show

  end

  def index
    @package_profiles = PackageProfile.order('name ASC').load
  end

  def edit
    authorize! :update, @package_profile
  end

  def update
    authorize! :update, @package_profile
    if @package_profile.update_attributes(allowed_params)
      redirect_to @package_profile
    else
      render 'edit'
    end
  end

  def new
    authorize! :create, PackageProfile
    @package_profile = PackageProfile.new
  end

  def create
    authorize! :create, PackageProfile
    @package_profile = PackageProfile.new(allowed_params)
    if @package_profile.save
      redirect_to @package_profile
    else
      render 'new'
    end
  end

  def destroy
    authorize! :destroy, @package_profile
    @package_profile.destroy
    redirect_to package_profiles_path
  end

  protected

  def find_package_profile
    @package_profile = PackageProfile.find(params[:id])
  end

  def allowed_params
    params[:package_profile].permit(:name, :notes, :url)
  end
end