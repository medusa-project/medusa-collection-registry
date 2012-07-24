class RepositoriesController < ApplicationController

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
    @repository = Repository.find(params[:id])
  end

  def index
    @repositories = Repository.all
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def update
    @repository = Repository.find(params[:id])
    if @repository.update_attributes(params[:repository])
      redirect_to repository_path(@repository)
    else
      render 'edit'
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy
    redirect_to repositories_path
  end

end
