class ItemsController < ApplicationController

  before_action :require_logged_in
  before_action :find_item_and_project, only: [:show, :edit, :update, :destroy]

  def show

  end

  def edit
    #authorize! :edit_item, @project
  end

  def update
    #authorize! :edit_item, @project
    if @item.update_attributes(allowed_params)
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
      @item = @source_item.dup
      @item.barcode = nil
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
          @items = @project.items(true)
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
    authorize! :delete_item, @project
    @item.destroy!
    redirect_to @item.project
  end

  def barcode_lookup
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
    params[:item].permit(:barcode, :local_title, :local_description, :notes, :batch, :file_count, :reformatting_date,
                         :reformatting_operator, :call_number, :title, :author, :imprint, :bib_id, :oclc_number, :record_series_id,
                         :archival_management_system_url, :series, :sub_series, :box, :folder, :item_title)
  end

end