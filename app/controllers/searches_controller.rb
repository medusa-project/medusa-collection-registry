class SearchesController < ApplicationController
  before_action :require_logged_in

  def filename
    @search_string = params[:search][:filename]
    #for SQL this needs to be quoted appropriately, then any wildcards handled
    db_search_string = @search_string.downcase.gsub('_', '\_').gsub('%', '\%').gsub('*', '%')
    #we use the lower(name) in conjunction with a like index on the column so that this LIKE search can be sped up
    @cfs_files = CfsFile.where('lower(name) LIKE ?', db_search_string).order('name asc').page(params[:page]).per_page(params[:per_page] || 25)
  end

end