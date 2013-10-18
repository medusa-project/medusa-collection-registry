class DirectoriesController < ApplicationController

  skip_before_filter :require_logged_in, :only => :show
  skip_before_filter :authorize, :only => :show

  def show
    @directory = Directory.find(params[:id])
    @path = @directory.self_and_ancestors
    @collection = Collection.find(@directory.collection_id)
    respond_to do |format|
      format.html
      format.json {render :json => show_json}
    end
  end

  protected

  def show_json
    Jbuilder.encode do |json|
      json.id @directory.id
      json.parent_directory_id @directory.parent_id
      json.collection_id @directory.collection_id
      json.root_directory_id @directory.root.id
      json.name @directory.name
      unless params[:include_subdirectories] == 'false'
        json.subdirectory_ids @directory.child_ids
      end
      json.path @directory.path_from_root
      if params[:include_files] == 'false'
        json.file_ids @directory.bit_file_ids
      else
        json.files @directory.bit_files do |file|
          json.id file.id
          json.md5sum file.md5sum
          json.name file.name
          json.content_type file.content_type
          json.ingested file.dx_ingested
          json.size file.size
          json.url file.dx_url
        end
      end
    end
  end
end