class RepositoriesController < ApplicationController

  before_filter :find_repository, :only => [:show, :edit, :update, :destroy]

  def new
    @repository = Repository.new
  end

  def create
    @repository = Repository.new(params[:repository])
    if @repository.save
      redirect_to repository_path(@repository)
    else
      render 'new'
    end
  end

  def show

  end

  def index
    @repositories = Repository.all
  end

  def edit

  end

  def update
    if @repository.update_attributes(params[:repository])
      redirect_to repository_path(@repository)
    else
      render 'edit'
    end
  end

  def destroy
    @repository.destroy
    redirect_to repositories_path
  end

  protected

  def find_repository
    @repository = Repository.find(params[:id])
  end

end
