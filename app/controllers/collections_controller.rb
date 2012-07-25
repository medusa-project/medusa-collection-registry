class CollectionsController < ApplicationController

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    @collection = Collection.new
    @repository = Repository.find(params[:repository_id])
  end

  # GET /collections/1/edit
  def edit
    @collection = Collection.find(params[:id])
    @repository = @collection.repository
  end

  def create
    @collection = Collection.new(params[:collection])

      if @collection.save
        redirect_to collection_path(@collection)
      else
        @repository = Repository.find(params[:collection][:repository_id])
        render "new"
    end
  end

  def update
    @collection = Collection.find(params[:id])
      if @collection.update_attributes(params[:collection])
        redirect_to collection_path(@collection)
      else
        @repository = @collection.repository
        render "edit"
      end
  end

  def destroy
    @collection = Collection.find(params[:id])
    repository = @collection.repository
    @collection.destroy
    redirect_to repository_path(repository)
  end
end
