class ItemsController < ApplicationController

  before_action :require_logged_in
  before_action :find_item_and_project, only: [:show, :edit, :update, :destroy]

  def show

  end

  def edit
    authorize! :edit_item, @project
  end

  def update
    authorize! :edit_item, @project
    if @item.update_attributes(allowed_params)
      redirect_to @project
    else
      render 'edit'
    end
  end

  def new
    @project = Project.find(params[:project_id])
    authorize! :create_item, @project
    @item = Item.new(project_id: @project.id)
    respond_to do |format|
      format.html
      format.js { @remote = true }
    end
  end

  def create
    @project = Project.find(params[:item][:project_id])
    authorize! :create_item, @project
    @item = @project.items.new(allowed_params)
    respond_to do |format|
      if @item.save
        format.html { redirect_to @project }
        format.js { @items = @project.items(true) }
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
    params[:item].permit(:barcode, :bib_id, :oclc_number, :call_number, :book_name, :title, :author,
                         :imprint, :photo_date, :notes)
  end

end