class ContentTypesController < ApplicationController
  before_action :require_medusa_user
  before_action :find_content_type

  def cfs_files
    @repository_id = params[:repository_id]
    @virtual_repository_id = params[:virtual_repository_id]
    @collection_id = params[:collection_id]
    @cfs_files = if @repository_id
                   @content_type.cfs_files.
                       joins(cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}).
                       where('collections.repository_id = ?', @repository_id).order('cfs_files.name asc').page(params[:page]).per_page(params[:per_page] || 25)
                 elsif @virtual_repository_id
                   @virtual_repository = VirtualRepository.find(@virtual_repository_id)
                   @content_type.cfs_files.
                       joins(cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}).
                       where('collections.id': @virtual_repository.collection_ids).order('cfs_files.name asc').
                       page(params[:page]).per_page(params[:per_page] || 25)
                 elsif @collection_id
                   @content_type.cfs_files.
                       joins(cfs_directory: {root_cfs_directory: :parent_file_group}).
                       where('file_groups.collection_id = ?', @collection_id).order('cfs_files.name asc').page(params[:page]).per_page(params[:per_page] || 25)
                 else
                   @content_type.cfs_files.order(:name).page(params[:page]).per_page(params[:per_page] || 25)
                 end
    @cfs_files = @cfs_files.includes(cfs_directory: {root_cfs_directory: {parent: :collection}})
  end

  def random_cfs_file
    redirect_to @content_type.random_cfs_file(params.slice(:repository_id, :virtual_repository_id, :collection_id))
  end

  protected

  def find_content_type
    @content_type = ContentType.find(params[:id])
  end

end
