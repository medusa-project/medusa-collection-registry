class PackageProfilesController < ApplicationController
  before_filter :find_package_profile, :only => [:show, :edit, :update, :destroy]
  skip_before_filter :require_logged_in, :only => [:show, :index]
  skip_before_filter :authorize, :only => [:show, :index]

  def show

  end

  def index
    @package_profiles = PackageProfile.order('name ASC').all
  end

  def edit

  end

  def update
    if @package_profile.update_attributes(params[:package_profile])
      redirect_to @package_profile
    else
      render 'edit'
    end
  end

  def new
    @package_profile = PackageProfile.new
  end

  def create
    @package_profile = PackageProfile.new(params[:package_profile])
    if @package_profile.save
      redirect_to @package_profile
    else
      render 'new'
    end
  end

  def destroy
    @package_profile.destroy
    redirect_to package_profiles_path
  end

  protected

  def find_package_profile
    @package_profile = PackageProfile.find(params[:id])
  end
end