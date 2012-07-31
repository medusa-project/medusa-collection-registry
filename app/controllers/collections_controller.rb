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
    update_or_create_contact
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
    net_id = params[:collection].delete(:contact_net_id)
    @collection = Collection.new(params[:collection])
    update_or_create_contact(net_id)
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
    @collection.build_contact unless @collection.contact
    @repository = @collection.repository
  end

  #I tried to find a good way to get the desired behavior using nested attributes, but failed
  def update_or_create_contact(net_id = nil)
    net_id ||= params[:collection][:contact_net_id].strip
    params[:collection].delete(:contact_net_id) if params[:collection].has_key?(:contact_net_id)
    if net_id.blank?
      @collection.contact = nil
    else
      @collection.contact = Person.find_or_create_by_net_id(net_id)
    end
  end

end
