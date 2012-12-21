class DirectoriesController < ApplicationController

  def show
    @directory = Directory.find(params[:id])
    @path = @directory.self_and_ancestors
    @collection = Collection.find(@directory.collection_id)
  end
end