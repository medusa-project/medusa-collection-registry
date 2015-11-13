class SearchesController < ApplicationController
  before_action :require_logged_in

  def filename
    @search_string = params[:search][:filename]
  end

  def file
    search_string = params[:search][:value]
    per_page = params[:length].to_i
    page = 1 + (params[:start].to_i / params[:length].to_i).floor
    columns = %i(name path file_group_title collection_title)
    order_column = params[:order]['0']['column']
    order_direction = params[:order]['0']['dir']
    @solr_search = CfsFile.search do
      fulltext search_string, fields: :name
      paginate page: page, per_page: per_page
      order_by columns[order_column.to_i], order_direction
    end
    @cfs_files = @solr_search.results
    response = {
        draw: params[:draw].to_i,
        recordsTotal: CfsFile.count,
        recordsFiltered: @solr_search.total,
        data: @cfs_files.collect {|cfs_file| file_row(cfs_file)}
    }
    respond_to do |format|
      format.json do
        render json: response.to_json
      end
    end
  end

  def file_row(cfs_file)
    file_group = cfs_file.try(:file_group)
    collection = file_group.try(:collection)
    Array.new.tap do |row|
      row << link_to(cfs_file.name, cfs_file_path(cfs_file))
      row << cfs_file.cfs_directory.path
      row << (file_group.present? ? link_to(file_group.title, file_group_path(file_group)) : '')
      row << (collection.present? ? link_to(collection.title, collection_path(collection)) : '')
    end
  end

  protected

  def link_to(*args)
    view_context.link_to(*args)
  end

end