class FileGroupsController < ApplicationController

  before_filter :find_file_group_and_collection, :only => [:show, :destroy, :edit, :update, :create_all_fits,
                                                           :new_event, :create_cfs_fits]
  skip_before_filter :require_logged_in, :only => [:show, :index]
  skip_before_filter :authorize, :only => [:show, :index]
  around_filter :handle_related_file_groups, :only => [:update, :create]

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
    handling_nested_collection_and_rights_declaration(params[:file_group]) do
      if @file_group.update_attributes(params[:file_group])
        redirect_to file_group_path(@file_group)
      else
        render 'edit'
      end
    end
  end

  def new
    @collection = Collection.find(params[:collection_id])
    @file_group = FileGroup.new(:collection_id => @collection.id)
    @file_group.rights_declaration = @file_group.clone_collection_rights_declaration
  end

  def create
    @collection = Collection.find(params[:file_group][:collection_id])
    klass = determine_creation_class(params[:file_group])
    handling_nested_collection_and_rights_declaration(params[:file_group]) do
      @file_group = klass.new(params[:file_group])
      if @file_group.save
        redirect_to file_group_path(@file_group)
      else
        render 'new'
      end
    end
  end

  def create_all_fits
    @file_group.delay.ensure_fits_xml_for_owned_bit_files
    record_event(@file_group, 'fits_performed')
    flash[:notice] = 'Scheduled creation of FITS XML'
    redirect_to file_group_path(@file_group)
  end

  def create_cfs_fits
    if @file_group.cfs_root.present?
      Cfs.delay.ensure_fits_for_tree(@file_group.cfs_root)
      record_event(@file_group, 'cfs_fits_performed')
      flash[:notice] = "Scheduling FITS creation for /#{@file_group.cfs_root}"
      redirect_to file_group_path(@file_group)
    end
  end

  def events
    @eventable = FileGroup.find(params[:id])
    render 'events/index'
  end

  def new_event
    no_redirect = params[:event].delete(:no_redirect)
    @file_group.events.create(params[:event].merge(:user_id => current_user.id))
    if no_redirect
      redirect_to :back
    else
      redirect_to file_group_path(@file_group)
    end
  end

  protected

  def find_file_group_and_collection
    @file_group = FileGroup.find(params[:id])
    @collection = @file_group.collection
  end

  #remove the related file group parameters, yield to the block, and after it completes upgrade the related file group stuff correctly
  def handle_related_file_groups
    related_file_group_ids = params[:file_group].delete(:related_file_group_ids)
    related_file_group_notes = params[:file_group].delete(:related_file_group_notes)
    yield
    @file_group.symmetric_update_related_file_groups(related_file_group_ids.reject { |id| id.blank? }, related_file_group_notes)
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

end
