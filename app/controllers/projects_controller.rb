class ProjectsController < ApplicationController

  before_action :require_medusa_user, except: [:index, :show, :public_show]
  before_action :find_project, only: [:show, :public_show, :edit, :update, :destroy, :attachments,
                                      :mass_action, :start_items_upload, :upload_items, :items]
  before_action :initialize_ingest_directory_info, only: [:new, :edit]

  include ModelsToCsv

  autocomplete :user, :email

  def index
    @projects = Project.order('title ASC')
    respond_to do |format|
      format.html
      format.csv { send_data projects_to_csv(@projects), type: 'text/csv', filename: 'projects.csv' }
    end
  end

  def new
    @collection = Collection.find(params[:collection_id])
    @project = Project.new
    @project.collection = @collection
    authorize! :create, @project
  end

  def create
    @project = Project.new(allowed_params)
    authorize! :create, @project
    if @project.save
      redirect_to @project
    else
      @collection = @project.collection
      render 'new'
    end
  end

  def edit
    authorize! :update, @project
    @collection = @project.collection
  end

  def update
    authorize! :update, @project
    authorize! :update, Collection.find(params[:project][:collection_id])
    if @project.update_attributes(allowed_params)
      redirect_to @project
    else
      render 'edit'
    end
  end

  def mass_action
    #authorize! :update, @project
    items = @project.items.where(id: params[:mass_action][:item])
    case params[:commit]
      when 'Mass update'
        mass_update(params[:mass_action])
      when 'Delete checked'
        items.destroy_all
      else
        raise RuntimeError, 'Unexpected mass action on project items'
    end
    respond_to do |format|
      format.html { redirect_to @project }
      format.js
    end

  end

  def show
    redirect_to public_show_project_path(@project) and return unless current_user
    @items = @project.items
    @batch = params[:batch]
    @items = @items.where(batch: @batch) if @batch.present?
    @helper = SearchHelper::TableItem.new(project: @project, batch: @batch)
    respond_to do |format|
      format.html
      format.csv { send_data items_to_csv(@items), type: 'text/csv', filename: 'items.csv' }
    end
  end

  def public_show

  end

  def items
    respond_to do |format|
      format.json do
        render json: SearchHelper::TableItem.new(params: params, project: @project, batch: params[:batch]).json_response
      end
    end
  end

  def destroy
    authorize! :destroy, @project
    if @project.destroy
      redirect_to projects_path
    else
      redirect_to :back, alert: 'Unknown error deleting project'
    end
  end

  def attachments
    @attachable = @project
  end

  def start_items_upload
    authorize! :update, @project
  end

  def upload_items
    authorize! :update, @project
    upload = params[:upload_items][:items]
    if upload
      @project.transaction do
        job = Job::ItemBulkImport.create!(user: current_user, project: @project, file_name: upload.original_filename)
        job.copy_csv_file(upload.tempfile.path)
        job.enqueue_job
      end
      redirect_to @project, notice: 'Your item upload job will be processed soon.'
    else
      redirect_to @project, notice: 'No items file attached'
    end
  end

  protected

  def find_project
    @project = Project.find(params[:id])
  end

  def allowed_params
    params[:project].permit(:title, :manager_email, :owner_email, :start_date,
                            :status, :specifications, :summary, :collection_id, :external_id,
                            :ingest_folder, :destination_folder_uuid)
  end

  def assign_batch(batch, items)
    items.find_each do |item|
      item.batch = batch
      item.save!
    end
  end

  def items_to_json(items)
    items.collect do |item|
      Array.new.tap do |row|
        row << link_to(item.barcode, item)
        row << item.bib_id
        row << [item.title, item.item_title, item.local_title].detect { |title| title.present? }
        row << item.notes
        row << link_to(item.batch, project_path(@project, batch: item.batch))
        row << check_box_tag('', item.id, false, name: 'assign_batch[assign][]', id: "assign_batch_assign_#{item.id}") if safe_can?(:update, @project)
        row << item.call_number
        row << item.author
        row << item.record_series_id
        row << small_edit_button(item) + ' ' + small_clone_button(new_item_path(source_id: item.id), method: :get)
      end
    end.to_json
  end

  MASS_UPDATE_FIELDS = [:batch, :reformatting_operator, :reformatting_date, :equipment]
  MASS_UPDATE_BOOLEANS = [:foldout_present, :foldout_done, :item_done, :ingested]

  def mass_update(params)
    item_ids = params[:item_ids].split(',')
    items = @project.items.where(id: item_ids)
    update_hash = Hash.new.tap do |updates|
      MASS_UPDATE_FIELDS.each do |field|
        updates[field] = params[field] if params["allow_blank_#{field}"] == '1' or params[field].present?
      end
      MASS_UPDATE_BOOLEANS.each do |field|
        updates[field] = true if params[field] == 'Yes'
        updates[field] = false if params[field] == 'No'
      end
    end
    items.each do |item|
      item.update!(update_hash)
    end
  end

  #TODO make this really work - this is just to get the view stuff going
  def initialize_ingest_directory_info
    @ingest_directory_info = {current: '/',
                              children: %w(child_1 child_2),
                              parent: nil}
  end

end