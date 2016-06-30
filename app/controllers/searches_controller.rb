class SearchesController < ApplicationController
  before_action :require_medusa_user

  def search
    @search_string = params[:search][:query] rescue ''
    @helpers = [SearchHelper::CfsFile, SearchHelper::CfsDirectory, SearchHelper::Item,
                SearchHelper::FileGroup, SearchHelper::Collection, SearchHelper::MedusaUuid].collect {|klass| klass.new(initial_search_string: @search_string)}
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

  def item
    respond_to do |format|
      format.json do
        render json: SearchHelper::Item.new(params: params).json_response
      end
    end
  end

  def file_group
    respond_to do |format|
      format.json do
        render json: SearchHelper::FileGroup.new(params: params).json_response
      end
    end
  end

  def collection
    respond_to do |format|
      format.json do
        render json: SearchHelper::Collection.new(params: params).json_response
      end
    end
  end

  def medusa_uuid
    respond_to do |format|
      format.json do
        render json: SearchHelper::MedusaUuid.new(params: params).json_response
      end
    end
  end

end