class FileGroupsController < ApplicationController

  before_action :require_medusa_user, except: [:show, :content_type_manifest]
  before_action :require_medusa_user_or_basic_auth, only: [:show, :content_type_manifest]
  before_action :find_file_group_and_collection, only: [:show, :destroy, :edit, :update, :create_cfs_fits,
                                                        :red_flags, :attachments,
                                                        :assessments, :events, :content_type_manifest,
                                                        :new_event]
  respond_to :html, :js, :json

  def show
    #This is a little funky to get the includes when we can
    @directory = @file_group.cfs_directory
    @directory = CfsDirectory.includes(:subdirectories, {cfs_files: [:content_type, :file_extension]}).find(@directory.id) if @directory.present?
    @accrual = create_accrual
    respond_to do |format|
      format.html do
        @directories_helper = SearchHelper::TableCfsDirectory.new(cfs_directory: @directory)
        @files_helper = SearchHelper::TableCfsFile.new(cfs_directory: @directory)
      end
      format.json
    end
  end

  def destroy
    authorize! :destroy, @file_group
    if @file_group.is_a?(ExternalFileGroup) or (@file_group.is_a?(BitLevelFileGroup) and @file_group.pristine?)
      if @file_group.destroy
        @collection.events.create!(key: :file_group_delete_empty, actor_email: current_user.email, note: "Deleted empty file group #{@file_group.id} titled #{@file_group.title}")
        redirect_to collection_path(@collection)
      else
        flash[:notice] = @file_group.errors.full_messages.join('\n')
        redirect_back fallback_location: @file_group
      end
    else
      redirect_to new_workflow_file_group_delete_path(file_group_id: @file_group.id)
    end
  end

  def edit
    authorize! :update, @file_group
    @active_tabs = params[:active_tab]
  end

  def update
    authorize! :update, @file_group
    handle_related_file_groups do
      if @file_group.update(allowed_params)
        redirect_to @file_group
      else
        render 'edit'
      end
    end
  end

  def new
    @collection = Collection.find(params[:collection_id])
    @file_group = FileGroup.new(collection_id: @collection.id)
    authorize! :create, @file_group
    @related_file_group_id = params[:related_file_group_id]
  end

  def create
    handle_related_file_groups do
      @collection = Collection.find(params[:file_group][:collection_id])
      klass = determine_creation_class(params[:file_group])
      @file_group = klass.new(collection: @collection)
      authorize! :create, @file_group
      @file_group.update(allowed_params)
      if @file_group.save
        @file_group.record_creation_event(current_user)
        redirect_to @file_group
      else
        render 'new'
      end
    end
  end

  def new_event
    authorize! :create_event, @file_group
    respond_to do |format|
      format.js
    end
  end

  def events
    @helper = SearchHelper::TableEvent.new(params: params, cascaded_eventable: @file_group)
    respond_to do |format|
      format.html
      format.json do
        render json: @helper.json_response
      end
    end
  end

  def red_flags
    @red_flags = @file_group.cascaded_red_flags
    @aggregator = @file_group
  end

  def attachments
    @attachable = @file_group
  end

  def assessments
    @assessable = @file_group
    @assessments = @assessable.assessments.order(date: :desc)
  end

  def content_type_manifest
    start = params[:start].try(:to_i) || 0
    count = params[:count].try(:to_i) || 10000
    count = [10000, count].min
    records = @file_group.try(:content_type_summary, start, count) || []
    response_hash = {start: start, requested_count: count, actual_count: [count, records.length].min, records: records}
    respond_to do |format|
      format.json do
        render json: response_hash
      end
    end
  end

  protected

  def find_file_group_and_collection
    @file_group = FileGroup.find(params[:id])
    @breadcrumbable = @file_group
    @collection = @file_group.collection
  end

  def determine_creation_class(params)
    FileGroup.class_for_storage_level(params.delete(:storage_level))
  end

  #remove the related file group parameters, yield to the block, and after it completes upgrade the related file group stuff correctly
  def handle_related_file_groups
    target_file_group_ids = params[:file_group].delete(:target_file_group_ids) || []
    target_file_group_notes = params[:file_group].delete(:target_file_group_notes) || []
    yield
    @file_group.target_file_group_ids = target_file_group_ids
    target_file_group_notes.each do |id, note|
      if join = RelatedFileGroupJoin.where(source_file_group_id: @file_group.id, target_file_group_id: id).first
        join.note = note
        join.save!
      end
    end
  end

  def allowed_params
    params[:file_group].permit(:collection_id, :external_file_location,
                               :producer_id, :description, :provenance_note, :acquisition_method, :contact_email,
                               :title, :staged_file_location, :total_file_size,
                               :total_files, :related_file_group_ids, :cfs_root,
                               :cfs_directory_id, :access_url)
  end

  def show_json
    Jbuilder.encode do |json|
      json.id @file_group.id
      json.title @file_group.title
      json.collection_id @collection.id
      json.external_file_location @file_group.external_file_location
      json.storage_level @file_group.json_storage_level
      if @file_group.cfs_directory.present?
        json.cfs_directory do
          directory = @file_group.cfs_directory
          json.id directory.id
          json.path cfs_directory_path(directory, format: :json)
          json.name directory.path
        end
      end
    end
  end

  def create_accrual
    Accrual.new(cfs_directory: @directory).decorate if @directory.present?
  end

end
