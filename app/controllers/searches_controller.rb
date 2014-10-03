class SearchesController < ApplicationController
  before_filter :require_logged_in

  SEARCH_LIMIT = 100

  def filename
    @search_string = params[:search][:filename]
    #for SQL this needs to be quoted appropriately, then any wildcards handled
    db_search_string = @search_string.downcase.gsub('_', '\_').gsub('%', '\%').gsub('*', '%')
    #we use the lower(name) in conjunction with a like index on the column so that this LIKE search can be speeded up
    @cfs_files = CfsFile.where('lower(name) LIKE ?', db_search_string).limit(SEARCH_LIMIT).order('name asc')
  end

end