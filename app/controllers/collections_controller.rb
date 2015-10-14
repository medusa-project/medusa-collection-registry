class CollectionsController < ApplicationController

  before_action :public_view_enabled?, only: [:public]
  before_action :require_logged_in, except: [:show, :public]
  before_action :require_logged_in_or_basic_auth, only: [:show]
  before_action :find_collection_and_repository, only: [:show, :destroy, :edit, :update, :red_flags, :public, :assessments, :attachments, :events]
  layout 'public', only: [:public]

  include ModelsToCsv

  def show
    @projects = @collection.projects
    respond_to do |format|
      format.html
      format.xml { render xml: @collection.to_mods }
      format.json
    end
  end

  def attachments
    @attachable = @collection
  end

  def assessments
    @assessable = @collection
    @assessments = @assessable.recursive_assessments
  end

  def public
    redirect_to unauthorized_path unless @collection.public?
    @public_object = @collection
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
    @collections = Collection.order(:title).includes(:repository, :preservation_priority, :contact)
    respond_to do |format|
      format.html
      format.csv { send_data collections_to_csv(@collections), type: 'text/csv', filename: 'collections.csv' }
    end
  end

  def red_flags
    @red_flags = @collection.cascaded_red_flags
    @aggregator = @collection
  end

  def events
    @eventable = Collection.find(params[:id])
    @events = @eventable.cascaded_events
  end

  protected

  def find_collection_and_repository
    @collection = Collection.find(params[:id])
    @collection.build_contact unless @collection.contact
    @breadcrumbable = @collection
    @repository = @collection.repository
  end

  def allowed_params
    params[:collection].permit(:access_url, :description, :private_description, :end_date, :notes,
                               :ongoing, :published, :repository_id, :start_date, :title,
                               :preservation_priority_id, :package_profile_id, :contact_email, :external_id,
                               rights_declaration_attributes: [:rights_basis, :copyright_jurisdiction, :copyright_statement,
                                                               :access_restrictions, :custom_copyright_statement, :id],
                               resource_type_ids: [], access_system_ids: []
    )
  end

end
