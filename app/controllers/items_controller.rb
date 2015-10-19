class ItemsController < ApplicationController

  before_action :require_logged_in
  before_action :find_item, only: [:show, :edit, :update, :destroy]

  def show

  end

  protected

  def find_item
    @item = Item.find(params[:id])
  end

end