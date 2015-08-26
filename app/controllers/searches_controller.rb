class SearchesController < ApplicationController
  before_action :require_logged_in

  def filename
    search = CfsFile.search do
      fulltext params[:search][:filename]
      paginate page: (params[:page] || 1), per_page: (params[:per_page] || 25)
    end
    @cfs_files = search.results
  end

end