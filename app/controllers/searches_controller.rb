class SearchesController < ApplicationController
  before_action :require_logged_in

  def filename
    #This funny business is because of the way the search block scopes - it
    #doesn't pick up the instance variable, but we need it for the view as well.
    @search_string = search_string = params[:search][:filename]
    @solr_search = CfsFile.search do
      fulltext search_string
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 25)
    end
    @cfs_files = @solr_search.results
  end

end