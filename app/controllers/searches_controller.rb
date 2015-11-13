class SearchesController < ApplicationController
  before_action :require_logged_in

  def search
    @search_string = params[:search][:query]
    @helpers = [SearchHelper::CfsFile.new(initial_search_string: @search_string)]
  end

  def cfs_file
    helper = SearchHelper::CfsFile.new(params: params, view_context: view_context)
    respond_to do |format|
      format.json do
        render json: helper.json_response
      end
    end
  end

end