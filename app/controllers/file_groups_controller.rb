class FileGroupsController < ApplicationController

  before_filter :find_file_group_and_collection, :only => [:show, :destroy, :edit, :update]
  skip_before_filter :require_logged_in, :only => [:show, :index]
  skip_before_filter :authorize, :only => [:show, :index]

  def show
    respond_to do |format|
      format.html
      format.json
    end
  end

  def destroy
    @file_group.destroy
    redirect_to collection_path(@collection)
  end

  def edit

  end

  def update
    if @file_group.update_attributes(params[:file_group])
      redirect_to file_group_path(@file_group)
    else
      render 'edit'
    end
  end

  def new
    @collection = Collection.find(params[:collection_id])
    @file_group = FileGroup.new(:collection_id => @collection.id)
    @file_group.rights_declaration = @file_group.clone_collection_rights_declaration
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

  protected

  def find_file_group_and_collection
    @file_group = FileGroup.find(params[:id])
    @collection = @file_group.collection
  end

end
