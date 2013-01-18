class DirectoriesController < ApplicationController

  skip_before_filter :require_logged_in, :only => :show
  skip_before_filter :authorize, :only => :show

  def show
    @directory = Directory.find(params[:id])
    @path = @directory.self_and_ancestors
    @collection = Collection.find(@directory.collection_id)
  end
end