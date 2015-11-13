class SearchesController < ApplicationController
  before_action :require_logged_in

  def search
    @search_string = params[:search][:query] rescue ''
    @helpers = [SearchHelper::CfsFile, SearchHelper::CfsDirectory].collect {|klass| klass.new(initial_search_string: @search_string)}
  end

  def cfs_file
    respond_to do |format|
      format.json do
        render json: SearchHelper::CfsFile.new(params: params).json_response
      end
    end
  end

  def cfs_directory
    respond_to do |format|
      format.json do
        render json: SearchHelper::CfsDirectory.new(params: params).json_response
      end
    end
  end

end