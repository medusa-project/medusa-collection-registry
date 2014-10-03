module BookTracker

  class ItemsController < ApplicationController

    def index
      @items = Item.all.paginate(page: params[:page], per_page: 100)
    end

    def show
      @item = Item.find(params[:id])
    end

  end

end
