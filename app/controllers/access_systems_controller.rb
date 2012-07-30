class AccessSystemsController < ApplicationController
  before_filter :find_access_system, :only => [:show, :edit, :update, :destroy]

  def index
    @access_systems = AccessSystem.all
  end

  def show

  end

  def edit

  end

  def update
    if @access_system.update_attributes(params[:access_system])
      redirect_to @access_system
    else
      render 'edit'
    end
  end

  def new
    @access_system = AccessSystem.new
  end

  def create
    @access_system = AccessSystem.new(params[:access_system])
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
end
