class CollectionsController < ApplicationController

  before_filter :find_collection_and_repository, :only => [:show, :destroy, :edit, :update, :red_flags]
  skip_before_filter :require_logged_in, :only => [:show, :index]
  skip_before_filter :authorize, :only => [:show, :index]

  def show
    @assessable = @collection
    @assessments = @assessable.recursive_assessments
    respond_to do |format|
      format.html
      format.xml {render :xml => @collection.to_mods}
      format.json
    end
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
    @collection.rights_declaration = @collection.build_rights_declaration
    @repository = Repository.find(params[:repository_id]) rescue Repository.order(:title).first
  end

  def create
    @collection = Collection.new(params[:collection])
    @repository = Repository.find(params[:collection][:repository_id]) rescue Repository.order(:title).first
    if @collection.save
      redirect_to collection_path(@collection)
    else
      render "new"
    end
  end

  def index
    @collections = Collection.order(:title).includes(:repository).all
  end

  def red_flags
    @red_flags = @collection.all_red_flags
    @aggregator = @collection
    render 'shared/red_flags'
  end

  def events
    @eventable = Collection.find(params[:id])
    @events = @eventable.all_events.sort_by(&:date).reverse
    render 'events/index'
  end

  protected

  def find_collection_and_repository
    @collection = Collection.find(params[:id])
    @collection.build_contact unless @collection.contact
    @repository = @collection.repository
  end

end
