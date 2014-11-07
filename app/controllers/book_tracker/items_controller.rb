module BookTracker

  class ItemsController < ApplicationController

    RESULTS_LIMIT = 50

    ##
    # Responds to both GET /book_tracker/items (and also POST due to search
    # form's ability to accept long lists of bib IDs)
    #
    def index
      @items = Item.all
      @missing_bib_ids = []

      @dates = {
          local_storage: Task.where(service: Service::LOCAL_STORAGE).
              where(status: Status::SUCCEEDED).last,
          hathitrust: Task.where(service: Service::HATHITRUST).
              where(status: Status::SUCCEEDED).last,
          internet_archive: Task.where(service: Service::INTERNET_ARCHIVE).
              where(status: Status::SUCCEEDED).last,
          google: Task.where(service: Service::GOOGLE).
              where(status: Status::SUCCEEDED).last
      }
      @dates.each{ |k, v| @dates[k] = v ? v.completed_at.strftime('%Y-%m-%d') : 'Never' }

      # query (q=)
      unless params[:q].blank?
        lines = params[:q].strip.split("\n")
        if lines.length > 1 # if >1 line, assume a newline-separated bib ID list
          @items = @items.where('bib_id IN (?)', lines.map{ |x| x.strip.gsub(/\D/, '')[0..8] })
          # Get a list of entered bib IDs for which items were not found
          sql = "SELECT * FROM "\
            "(values #{lines.map{ |x| "(#{x.strip[0..8]})" }.join(',')}) as T(ID) "\
            "EXCEPT "\
            "SELECT bib_id "\
            "FROM book_tracker_items;"
          @missing_bib_ids = ActiveRecord::Base.connection.execute(sql).
              map{ |r| r['id'] }
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

      next_page = params[:page].to_i > 1 ? params[:page].to_i + 1 : 2
      # TODO: set this to nil if there is no next page
      @next_page_url = book_tracker_items_path(params.merge(page: next_page))

      if request.xhr?
        @items = @items.paginate(page: params[:page], per_page: RESULTS_LIMIT)
        render partial: 'item_rows', locals: { items: @items,
                                               next_page_url: @next_page_url }
      else
        respond_to do |format|
          format.html {
            @items = @items.paginate(page: params[:page],
                                     per_page: RESULTS_LIMIT)
          }
          format.csv {
            items_csv = @items.to_csv
            @missing_bib_ids.each do |id|
              items_csv << id
            end
            send_data(items_csv)
          }
        end
      end
    end

    def show
      @item = Item.find(params[:id])
    end

  end

end
