module BookTracker

  class ItemsController < ApplicationController

    ##
    # Responds to both GET /book_tracker/items (and also POST due to search
    # form's ability to accept long lists of bib IDs)
    #
    def index
      @items = Item.all

      # query (q=)
      unless params[:q].blank?
        lines = params[:q].strip.split("\n")
        if lines.length > 1 # if >1 line, assume a newline-separated bib ID list
          @items = @items.where('CAST(bib_id AS VARCHAR(10)) IN (?)',
                                lines.map{ |x| x.strip })
        else
          q = "%#{params[:q]}%"
          @items = @items.where('CAST(bib_id AS VARCHAR(10)) LIKE ? '\
          'OR oclc_number LIKE ? OR obj_id LIKE ? OR LOWER(title) LIKE LOWER(?) '\
          'OR LOWER(author) LIKE LOWER(?) OR LOWER(ia_identifier) LIKE LOWER(?)' \
          'OR LOWER(date) LIKE LOWER(?)', q, q, q, q, q, q, q)
        end
      end

      # in/not-in service (in[]=, ni[]=)
      if params[:in].kind_of?(Array) and params[:ni].kind_of?(Array) and
          (params[:in] & params[:ni]).length > 0
        flash[:error] = 'Cannot search for items that are both in and not in '\
        'the same service.'
      else
        if params[:in].kind_of?(Array)
          params[:in].each do |service|
            case service
              when 'ht'
                @items = @items.where(exists_in_hathitrust: true)
              when 'ia'
                @items = @items.where(exists_in_internet_archive: true)
              when 'gb'
                @items = @items.where(exists_in_google: true)
            end
          end
        end
        if params[:ni].kind_of?(Array)
          params[:ni].each do |service|
            case service
              when 'ht'
                @items = @items.where(exists_in_hathitrust: false)
              when 'ia'
                @items = @items.where(exists_in_internet_archive: false)
              when 'gb'
                @items = @items.where(exists_in_google: false)
            end
          end
        end

        @items = @items.order(:title)
      end

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
