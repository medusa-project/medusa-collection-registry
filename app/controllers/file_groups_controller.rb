class FileGroupsController < ApplicationController

  def show
    @file_group = FileGroup.find(params[:id])
    @collection = @file_group.collection
  end

  def destroy
    file_group = FileGroup.find(params[:id])
    collection = file_group.collection
    file_group.destroy
    redirect_to collection_path(collection)
  end

  def edit
    @file_group = FileGroup.find(params[:id])
    @collection = @file_group.collection
  end

  def update
    @file_group = FileGroup.find(params[:id])
    @collection = @file_group.collection
    if @file_group.update_attributes(params[:file_group])
      redirect_to file_group_path(@file_group)
    else
      render 'edit'
    end
  end

  def new
    @collection = Collection.find(params[:collection_id])
    @file_group = FileGroup.new(:collection_id => @collection.id)
  end

  def create
    @collection = Collection.find(params[:file_group][:collection_id])
    @file_group = FileGroup.new(params[:file_group])
    if @file_group.save
      redirect_to file_group_path(@file_group)
    else
      render 'new'
    end
  end
end
