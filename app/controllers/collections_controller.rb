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

  def for_access_system
    access_system = AccessSystem.find(params[:access_system_id])
    @collections = access_system.collections.order(:title).includes(:repository)
    @subheader = "For Access system: #{access_system.name}"
    render 'index'
  end

  def for_package_profile
    package_profile = PackageProfile.find(params[:package_profile_id])
    file_groups = package_profile.file_groups.includes(:collection => :repository)
    @collections = file_groups.collect do |file_group|
      file_group.collection
    end.uniq.sort_by(&:title)
    @subheader = "For Package Profile: #{package_profile.name}"
    render 'index'
  end

  def red_flags
    @red_flags = @collection.all_red_flags
    @aggregator = @collection
    render 'shared/red_flags'
  end

  def events
    @scheduled_eventable = @eventable = Collection.find(params[:id])
    @events = @eventable.all_events.sort_by(&:date).reverse
    @scheduled_events = @scheduled_eventable.all_scheduled_events.sort_by(&:action_date)
  end

  protected

  def find_collection_and_repository
    @collection = Collection.find(params[:id])
    @collection.build_contact unless @collection.contact
    @repository = @collection.repository
  end

end
