module BookTracker

  class ItemsController < ApplicationController

    def index
      q = "%#{params[:q]}%"
      @items = Item.all
      @items = @items.where('CAST(bib_id AS VARCHAR(10)) LIKE ? '\
        'OR oclc_number LIKE ? OR obj_id LIKE ? OR LOWER(title) LIKE LOWER(?) '\
        'OR LOWER(author) LIKE LOWER(?) OR LOWER(ia_identifier) LIKE LOWER(?)',
        q, q, q, q, q, q) unless params[:q].blank?
      @items = @items.where(exists_in_hathitrust: params[:ht]) unless params[:ht].blank?
      @items = @items.where(exists_in_internet_archive: params[:ia]) unless params[:ia].blank?
      @items = @items.order(:title)

      @messages = []
      @messages << "Containing \"#{params[:q]}\"" unless params[:q].blank?
      @messages << 'In HathiTrust' if !params[:ht].blank? and params[:ht] == '1'
      @messages << 'In Internet Archive' if !params[:ia].blank? and params[:ia] == '1'
      @messages << 'Not in HathiTrust' if params[:ht] == '0'
      @messages << 'Not in Internet Archive' if params[:ia] == '0'

      respond_to do |format|
        format.html {
          @items = @items.paginate(page: params[:page], per_page: 100)
        }
        format.csv { send_data @items.to_csv }
        format.js {
          @items = @items.paginate(page: params[:page], per_page: 100)
        }
        format.xls { send_data @items.to_csv(col_sep: "\t") }
      end
    end

    def show
      @item = Item.find(params[:id])
    end

  end

end
