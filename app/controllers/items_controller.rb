class ItemsController < ApplicationController

  before_action :require_logged_in
  before_action :find_item, only: [:show, :edit, :update, :destroy]

  def show

  end

  def edit

  end

  def update
    if @item.update(allowed_params)
      redirect_to @item.project
    else
      render 'edit'
    end
  end

  def new
    @item = Item.new(project_id: params[:project_id])
  end

  def create
    @project = Project.find(params[:item][:project_id])
    @item = @project.items.new(allowed_params)
    if @item.save
      redirect_to @project
    else
      render 'new'
    end
  end

  protected

  def find_item
    @item = Item.find(params[:id])
  end

  def allowed_params
    params[:item].permit(:barcode, :bib_id, :oclc_number, :call_number, :book_name, :title, :author,
                         :imprint, :photo_date, :special_notes, :tif_completed, :qa_tif, :transferred_to_medusa, :transferred_to_hathi)
  end

end