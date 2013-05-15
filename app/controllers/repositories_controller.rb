class RepositoriesController < ApplicationController

  before_filter :find_repository, :only => [:show, :edit, :update, :destroy, :red_flags]
  skip_before_filter :require_logged_in, :only => [:show, :index]
  skip_before_filter :authorize, :only => [:show, :index]

  def new
    @repository = Repository.new
  end

  def create
    @repository = Repository.new(params[:repository])
    if @repository.save
      redirect_to repository_path(@repository), notice: 'Repository was successfully created.'
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
      redirect_to repository_path(@repository), notice: 'Repository was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @repository.destroy
    redirect_to repositories_path
  end

  def red_flags
    @red_flags = @repository.all_red_flags
    @aggregator = Hash.new
    @aggregator[:label] = @repository.title
    @aggregator[:path] = repository_path(@repository)
    render 'shared/red_flags'
  end

  protected

  def find_repository
    @repository = Repository.find(params[:id])
  end

end
