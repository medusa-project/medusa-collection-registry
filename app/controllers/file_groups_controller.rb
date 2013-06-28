class FileGroupsController < ApplicationController

  before_filter :find_file_group_and_collection, :only => [:show, :destroy, :edit, :update, :create_all_fits,
                                                           :create_cfs_fits, :create_virus_scan, :red_flags]
  skip_before_filter :require_logged_in, :only => [:show]
  skip_before_filter :authorize, :only => [:show]
  around_filter :handle_related_file_groups, :only => [:update, :create]
  respond_to :html, :js, :json

  def show
    @assessable = @file_group
    @assessments = @assessable.assessments.order('date DESC')
    respond_to do |format|
      format.html
      format.json {render :json => show_json}
    end
  end

  def destroy
    @file_group.destroy
    redirect_to collection_path(@collection)
  end

  def edit
    @active_tabs = params[:active_tab]
  end

  def update
    handling_nested_collection_and_rights_declaration(params[:file_group]) do
      if @file_group.update_attributes(allowed_params)
        redirect_to @file_group
      else
        render 'edit'
      end
    end
  end

  def new
    @collection = Collection.find(params[:collection_id])
    @file_group = FileGroup.new(:collection_id => @collection.id)
    @file_group.rights_declaration = @file_group.clone_collection_rights_declaration
    @related_file_group_id = params[:related_file_group_id]
  end

  def create
    @collection = Collection.find(params[:file_group][:collection_id])
    klass = determine_creation_class(params[:file_group])
    handling_nested_collection_and_rights_declaration(allowed_params) do
      @file_group = klass.new(allowed_params)
      if @file_group.save
        redirect_to @file_group
      else
        render 'new'
      end
    end
  end

  def create_cfs_fits
    if @file_group.cfs_root.present?
      Delayed::Job.enqueue(Job::FitsDirectoryTree.create(:path => @file_group.cfs_root), :priority => 50)
      record_event(@file_group, 'cfs_fits_performed')
      flash[:notice] = "Scheduling FITS creation for /#{@file_group.cfs_root}"
      redirect_to @file_group
    end
  end

  def create_virus_scan
    if @file_group.cfs_root.present?
      @alert = "Running virus scan on cfs directory #{@file_group.cfs_root}."
      Delayed::Job.enqueue(Job::VirusScan.create(:file_group_id => @file_group.id), :priority => 20)
    else
      @alert = 'Selected File Group does not have a cfs root directory'
    end
    respond_to do |format|
      format.js
    end
  end

  def events
    @eventable = FileGroup.find(params[:id])
    @events = @eventable.events
    @scheduled_eventable = @eventable
    @scheduled_events = @scheduled_eventable.scheduled_events
  end

  def red_flags
    @red_flags = @file_group.all_red_flags
    @aggregator = @file_group
    render 'shared/red_flags'
  end

  protected

  def find_file_group_and_collection
    @file_group = FileGroup.find(params[:id])
    @collection = @file_group.collection
  end

  #Ideally we'd handle this with nested attributes, but I can't seem to get the combination of STI on the file group
  #and nested attributes to work correctly, so here we are. It's not too bad since the file group will already exist
  #and is guaranteed to have both a collection and rights declaration, making both of those just updates.
  def handling_nested_collection_and_rights_declaration(params)
    collection_params = params.delete(:collection)
    rights_params = params.delete(:rights_declaration)
    FileGroup.transaction do
      yield
      @file_group.collection.update_attributes!(collection_params)
      @file_group.rights_declaration.update_attributes!(rights_params)
    end
  end

  def determine_creation_class(params)
    storage_level = params.delete(:storage_level)
    Kernel.const_get(FileGroup::STORAGE_LEVEL_HASH.detect { |k, v| v == storage_level }.first)
  end

  #remove the related file group parameters, yield to the block, and after it completes upgrade the related file group stuff correctly
  def handle_related_file_groups
    target_file_group_ids = params[:file_group].delete(:target_file_group_ids) || []
    target_file_group_notes = params[:file_group].delete(:target_file_group_notes) || []
    yield
    @file_group.target_file_group_ids = target_file_group_ids
    target_file_group_notes.each do |id, note|
      if join = RelatedFileGroupJoin.where(:source_file_group_id => @file_group.id, :target_file_group_id => id).first
        join.note = note
        join.save!
      end
    end
  end

  def allowed_params
    params[:file_group].permit(:collection_id, :external_file_location,
                               :producer_id, :file_type_id, :summary, :provenance_note,
                               :name, :staged_file_location, :total_file_size,
                               :file_format, :total_files, :related_file_group_ids, :cfs_root,
                               :package_profile_id)
  end

  def show_json
    Jbuilder.encode do |json|
      json.id @file_group.id
      json.root_directory_id @file_group.root_directory_id
      json.collection_id @collection.id
      json.external_file_location @file_group.external_file_location
      json.type @file_group.file_type_name
    end
  end

end
