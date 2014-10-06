module BookTracker

  class ItemsController < ApplicationController

    def index
      q = "%#{params[:q]}%"
      @items = Item.where('CAST(bib_id AS VARCHAR(10)) LIKE ? '\
        'OR oclc_number LIKE ? OR obj_id LIKE ? OR LOWER(title) LIKE LOWER(?) '\
        'OR LOWER(author) LIKE LOWER(?) OR LOWER(ia_identifier) LIKE LOWER(?)',
        q, q, q, q, q, q).
          order(:title).paginate(page: params[:page], per_page: 100)
    end

    def show
      @item = Item.find(params[:id])
    end

  end

end
