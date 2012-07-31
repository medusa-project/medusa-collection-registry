class CollectionsController < ApplicationController

  before_filter :find_collection_and_repository, :only => [:show, :destroy, :edit, :update]

  def show

  end

  def destroy
    @collection.destroy
    redirect_to repository_path(@repository)
  end

  def edit

  end

  def update
    if @collection.update_attributes(params[:collection])
      redirect_to collection_path(@collection)
    else
      render "edit"
    end
  end

  def new
    @collection = Collection.new
    @repository = Repository.find(params[:repository_id])
  end

  def create
    @collection = Collection.new(params[:collection])
    @repository = Repository.find(params[:collection][:repository_id])
    if @collection.save
      redirect_to collection_path(@collection)
    else
      render "new"
    end
  end

  def index
    @collections = Collection.order(:title).includes(:repository).all
  end

  protected

  def find_collection_and_repository
    @collection = Collection.find(params[:id])
    @repository = @collection.repository
  end

end
