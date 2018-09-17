module BookTracker

  class ItemsController < ApplicationController

    RESULTS_LIMIT = 100

    before_action :setup

    def setup
      @allowed_params = params.permit(:action, :controller, :format, :harvest,
                                      :ht, :ia, :id, :last_modified_after,
                                      :last_modified_before, :page, :q,
                                      in: [], ni: [])
    end

    ##
    # Responds to both GET /book_tracker/items (and also POST due to search
    # form's ability to accept long lists of bib IDs).
    #
    def index
      @items = Item.all
      @missing_ids = []

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
      query = @allowed_params[:q]
      if query.present?
        lines = query.strip.split("\n")
        # If >1 line, assume a list of bib and/or object IDs.
        if lines.length > 1
          bib_ids = lines.select{ |id| id.length < 8 }.map{ |x| x.strip }
          object_ids = lines.select{ |id| id.length > 8 }.map{ |x| x.strip[0..20] }

          @items = @items.where('bib_id::char IN (?) OR obj_id IN (?)',
                                bib_ids, object_ids)
          # Compile a list of entered IDs for which items were not found.
          if bib_ids.any?
            sql = "SELECT * FROM "\
              "(values #{bib_ids.map{ |id| "('#{id}')" }.join(',')}) as T(ID) "\
              "EXCEPT "\
              "SELECT bib_id::char "\
              "FROM book_tracker_items;"
            @missing_ids += ActiveRecord::Base.connection.execute(sql).map{ |r| r['id'] }
          end
          if object_ids.any?
            sql = "SELECT * FROM "\
              "(values #{object_ids.map{ |id| "('#{id}')" }.join(',')}) as T(ID) "\
              "EXCEPT "\
              "SELECT obj_id "\
              "FROM book_tracker_items;"
            @missing_ids += ActiveRecord::Base.connection.execute(sql).map{ |r| r['id'] }
          end
        else
          q = "%#{query.strip}%"
          @items = @items.where('CAST(bib_id AS VARCHAR(10)) LIKE ? '\
          'OR oclc_number LIKE ? OR obj_id LIKE ? OR LOWER(title) LIKE LOWER(?) '\
          'OR LOWER(author) LIKE LOWER(?) OR LOWER(ia_identifier) LIKE LOWER(?)' \
          'OR LOWER(date) LIKE LOWER(?)', q, q, q, q, q, q, q)
        end
      end

      # in/not-in service (in[]=, ni[]=)
      # These are used by checkboxes in the items UI.
      if @allowed_params[:in].respond_to?(:each) and
          @allowed_params[:ni].respond_to?(:each) and
          (@allowed_params[:in] & @allowed_params[:ni]).length > 0
        flash['error'] = 'Cannot search for items that are both in and not in '\
            'the same service.'
      else
        if @allowed_params[:in].respond_to?(:each)
          @allowed_params[:in].each do |service|
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
        if @allowed_params[:ni].respond_to?(:each)
          @allowed_params[:ni].each do |service|
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

      # Harvest mode (harvest=true) uses a query that the web UI can't generate.
      if @allowed_params[:harvest] == 'true'
        # Exclude Hathitrust-restricted items (DLDS-70)
        @items = @items.where('hathitrust_access != ?', 'deny')

        # Include only books that don't solely exist, or don't exist at all,
        # in Google, due to difficulty in linking to them.
        @items = @items.where('exists_in_google = ? OR exists_in_hathitrust = ? OR exists_in_internet_archive = ?',
                              false, true, true)

        if @allowed_params[:last_modified_after].present? # epoch seconds
          @items = @items.where('updated_at >= ?',
                                Time.at(@allowed_params[:last_modified_after].to_i))
        end
        if @allowed_params[:last_modified_before].present? # epoch seconds
          @items = @items.where('updated_at <= ?',
                                Time.at(@allowed_params[:last_modified_before].to_i))
        end
      end

      page = @allowed_params[:page].to_i
      page = 1 if page < 1
      next_page = page + 1
      # TODO: set this to nil if there is no next page
      @allowed_params.permit!
      @next_page_url = book_tracker_items_path(@allowed_params.merge(page: next_page))

      if request.xhr?
        @items = @items.paginate(page: page, per_page: RESULTS_LIMIT)
        render partial: 'item_rows', locals: { items: @items,
                                               next_page_url: @next_page_url }
      else
        respond_to do |format|
          format.html do
            @items = @items.paginate(page: page, per_page: RESULTS_LIMIT)
          end
          format.json do
            @items = @items.paginate(page: page, per_page: RESULTS_LIMIT)
            @items.each{ |item| item.url = url_for(item) }
            render json: {
                numResults: @items.total_entries,
                windowSize: RESULTS_LIMIT,
                windowOffset: (page - 1) * RESULTS_LIMIT,
                results: @items
            }, except: :raw_marcxml
          end
          format.csv do
            # Use Enumerator in conjunction with some custom headers to
            # stream the results, as an alternative to send_data
            # which would require them to be loaded into memory first.
            enumerator = Enumerator.new do |y|
              y << Item::CSV_HEADER.to_csv
              # Item.uncached disables ActiveRecord caching that would prevent
              # previous find_each batches from being garbage-collected.
              Item.uncached { @items.find_each { |item| y << item.to_csv } }
            end
            stream(enumerator, 'items.csv', 'text/csv')
          end
          format.xml do
            enumerator = Enumerator.new do |y|
              y << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<export>\n"
              Item.uncached do
                @items.find_each { |item| y << item.raw_marcxml + "\n" }
              end
              y << '</export>'
            end
            stream(enumerator, 'items.xml', 'application/xml')
          end
        end
      end
    end

    def show
      @item = Item.find(params[:id])
      respond_to do |format|
        format.html {}
        format.json { render json: @item }
      end
    end

    private

    ##
    # Sends an Enumerable in chunks as an attachment. Streaming requires a
    # web server capable of it (not WEBrick or Thin).
    #
    def stream(enumerable, filename, content_type)
      self.response.headers['X-Accel-Buffering'] = 'no'
      self.response.headers['Cache-Control'] ||= 'no-cache'
      self.response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      self.response.headers['Content-Type'] = content_type
      self.response.headers.delete('Content-Length')
      self.response_body = enumerable
    end

  end

end
