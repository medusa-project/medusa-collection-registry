class FileGroupsController < ApplicationController

  before_filter :find_file_group_and_collection, :only => [:show, :destroy, :edit, :update, :create_all_fits]
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

  def create_all_fits
    @file_group.delay.ensure_fits_xml_for_owned_bit_files
    record_event(@file_group, 'FITS analysis performed')
    flash[:notice] = 'Scheduled creation of FITS XML'
    redirect_to file_group_path(@file_group)
  end

  def events
    @eventable = FileGroup.find(params[:id])
    render 'events/index'
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

end
