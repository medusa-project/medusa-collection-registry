class CollectionsController < ApplicationController

  before_filter :require_logged_in, except: [:show, :public]
  before_filter :require_logged_in_or_basic_auth, only: [:show]
  before_filter :find_collection_and_repository, only: [:show, :destroy, :edit, :update, :red_flags, :public]
  include CollectionsToCsv

  def show
    @assessable = @collection
    @assessments = @assessable.recursive_assessments
    respond_to do |format|
      format.html
      format.xml { render xml: @collection.to_mods }
      format.json
    end
  end

  def public
    redirect_to unauthorized_path unless @collection.public?
    @public_file_groups = @collection.file_groups.order('created_at').select {|file_group| file_group.public? and file_group.is_a?(BitLevelFileGroup)}
  end

  def destroy
    authorize! :destroy, @collection
    @collection.destroy
    redirect_to repository_path(@repository)
  end

  def edit
    authorize! :update, @collection
  end

  def update
    authorize! :update, @collection
    if @collection.update_attributes(allowed_params)
      redirect_to collection_path(@collection)
    else
      render 'edit'
    end
  end

  def new
    @collection = Collection.new
    @collection.rights_declaration = RightsDeclaration.new(rights_declarable_type: 'Collection')
    @repository = Repository.find(params[:repository_id]) rescue Repository.order(:title).first
    @collection.repository = @repository
    authorize! :create, @collection
  end

  def create
    #this is a tiny bit unintuitive, but we have to do enough at the start to perform authorization
    @repository = Repository.find(params[:collection][:repository_id]) rescue Repository.order(:title).first
    @collection = Collection.new
    @collection.repository = @repository
    authorize! :create, @collection
    if @collection.update_attributes(allowed_params)
      redirect_to collection_path(@collection)
    else
      render 'new'
    end
  end

  def index
    #Getting file groups and cfs_directories speeds things up considerably for an initial generation of the view,
    #but slows it down a bit when most of the rows are cached. I don't know how to decide ahead of time, so
    #I have chosen this way of doing it to reduce the maximum time.
    @collections = Collection.order(:title).includes(:repository, :file_groups => :cfs_directory)
    respond_to do |format|
      format.html
      format.csv { send_data collections_to_csv(@collections), type: 'text/csv', filename: 'collections.csv' }
    end
  end

  def for_access_system
    access_system = AccessSystem.find(params[:access_system_id])
    @collections = access_system.collections.order(:title).includes(:repository)
    @subheader = "For Access system: #{access_system.name}"
    render 'index'
  end

  def for_package_profile
    package_profile = PackageProfile.find(params[:package_profile_id])
    file_groups = package_profile.file_groups.includes(collection: :repository)
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
    @scheduled_events = @scheduled_eventable.incomplete_scheduled_events.sort_by(&:action_date)
  end

  protected

  def find_collection_and_repository
    @collection = Collection.find(params[:id])
    @collection.build_contact unless @collection.contact
    @repository = @collection.repository
  end

  def allowed_params
    params[:collection].permit(:access_url, :description, :private_description, :end_date, :file_package_summary, :notes,
                               :ongoing, :published, :repository_id, :start_date, :title,
                               :preservation_priority_id, :package_profile_id, :contact_email, :external_id,
                               rights_declaration_attributes: [:rights_basis, :copyright_jurisdiction, :copyright_statement, :access_restrictions],
                               resource_type_ids: [], access_system_ids: []
    )
  end

end
