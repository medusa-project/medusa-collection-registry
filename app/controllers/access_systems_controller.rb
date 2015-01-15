class AccessSystemsController < ApplicationController

  before_filter :require_logged_in, except: [:index, :show]
  before_filter :find_access_system, only: [:show, :edit, :update, :destroy, :collections]

  def index
    @access_systems = AccessSystem.all
  end

  def show

  end

  def edit
    authorize! :update, @access_system
  end

  def update
    authorize! :update, @access_system
    if @access_system.update_attributes(allowed_params)
      redirect_to @access_system
    else
      render 'edit'
    end
  end

  def new
    authorize! :create, AccessSystem
    @access_system = AccessSystem.new
  end

  def create
    authorize! :create, AccessSystem
    @access_system = AccessSystem.new(allowed_params)
    if @access_system.save
      redirect_to @access_system
    else
      render 'new'
    end
  end

  def destroy
    authorize! :destroy, @access_system
    @access_system.destroy
    redirect_to access_systems_path
  end

  def collections
    @collections = @access_system.collections.order(:title).includes(:repository)
    @subheader = "For Access system: #{@access_system.name}"
  end

  protected

  def find_access_system
    @access_system = AccessSystem.find(params[:id])
  end

  def allowed_params
    params[:access_system].permit(:name, :service_owner, :application_manager)
  end

end
