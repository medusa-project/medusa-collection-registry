class ItemsController < ApplicationController

  before_action :require_medusa_user
  before_action :find_item_and_project, only: [:show, :edit, :update, :destroy]

  def index
    if params['barcode']
      @items = Item.where(barcode: params['barcode'].strip)
      respond_to do |format|
        format.json do
          if @items.count.positive?
            render json: @items.as_json
          else
            render json: {negative: params}
          end
        end
      end
    else
      render json: params
    end

  end

  def show

  end

  def edit
    #authorize! :edit_item, @project
  end

  def update
    #authorize! :edit_item, @project
    if @item.update(allowed_params)
      redirect_to @project
    else
      render 'edit'
    end
  end

  def new
    if params[:source_id]
      @source_item = Item.find(params[:source_id])
      @project = @source_item.project
      authorize! :create_item, @project
      @item = clone_item(@source_item)
    else
      @project = Project.find(params[:project_id])
      authorize! :create_item, @project
      @item = Item.new(project_id: @project.id)
    end
    respond_to do |format|
      format.html
      format.js { @remote = true }
    end
  end

  def create
    @project = Project.find(params[:item][:project_id])
    authorize! :create_item, @project
    @item = @project.items.new(allowed_params)
    @do_another = params[:commit] == 'Create'
    respond_to do |format|
      if @item.save
        format.html do
          redirect_to @do_another ? new_item_path : @project
        end
        format.js do
          @items = @project.items.reload
        end
      else
        format.html { render 'new' }
        format.js do
          @remote = true
          render 'new'
        end
      end
    end
  end

  def destroy
    authorize! :destroy_item, @project
    @item.destroy!
    redirect_to @item.project
  end

  def barcode_lookup
    #Rails.logger.warn("barcode lookup params: #{params.to_yaml}")
    respond_to do |format|
      format.json do
        render json: BarcodeLookup.new(params[:barcode].strip).item_hashes
      end
    end
  end

  protected

  def find_item_and_project
    @item = Item.find(params[:id])
    @project = @item.project
  end

  def allowed_params
    params[:item].permit(:barcode, :item_number, :local_title, :local_description, :notes, :batch, :file_count, :status, :reformatting_date,
                         :reformatting_operator, :equipment, :foldout_present, :foldout_done, :item_done, :ingested, :unique_identifier, :source_media,
                         :call_number, :title, :author, :imprint, :bib_id, :oclc_number,
                         :record_series_id, :archival_management_system_url, :series, :sub_series, :box, :folder,
                         :item_title, :creator, :date, :rights_information, :requester_info, :ebook_status, :external_link, :reviewed_by)
  end

  def clone_item(source)
    source.dup.tap do |clone|
      clone.barcode = nil
      clone.ingested = false
    end
  end

end