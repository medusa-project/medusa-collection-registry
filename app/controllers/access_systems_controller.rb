class AccessSystemsController < ApplicationController
  before_filter :find_access_system, :only => [:show, :edit, :update, :destroy]
  skip_before_filter :require_logged_in, :only => [:show, :index]
  skip_before_filter :authorize, :only => [:show, :index]

  def index
    @access_systems = AccessSystem.all
  end

  def show

  end

  def edit

  end

  def update
    if @access_system.update_attributes(allowed_params)
      redirect_to @access_system
    else
      render 'edit'
    end
  end

  def new
    @access_system = AccessSystem.new
  end

  def create
    @access_system = AccessSystem.new(allowed_params)
    if @access_system.save
      redirect_to @access_system
    else
      render 'new'
    end
  end

  def destroy
    @access_system.destroy
    redirect_to access_systems_path
  end

  protected

  def find_access_system
    @access_system = AccessSystem.find(params[:id])
  end

  def allowed_params
    params[:access_system].permit(:name)
  end
end
