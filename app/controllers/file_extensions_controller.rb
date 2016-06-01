class FileExtensionsController < ApplicationController
  before_action :require_medusa_user
  before_action :find_file_extension

  def cfs_files
    @repository_id = params[:repository_id]
    @virtual_repository_id = params[:virtual_repository_id]
    @cfs_files = if @repository_id
                   @file_extension.cfs_files.
                       joins(cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}).
                       where('collections.repository_id = ?', @repository_id).order('cfs_files.name asc').page(params[:page]).per_page(params[:per_page] || 25)
                 elsif @virtual_repository_id
                   @virtual_repository = VirtualRepository.find(@virtual_repository_id)
                   @file_extension.cfs_files.
                       joins(cfs_directory: {root_cfs_directory: {parent_file_group: :collection}}).
                       where('collections.id': @virtual_repository.collection_ids).order('cfs_files.name asc').
                       page(params[:page]).per_page(params[:per_page] || 25)
                 else
                   @file_extension.cfs_files.order('name asc').page(params[:page]).per_page(params[:per_page] || 25)
                 end
  end

  def fits_batch
    authorize! :create, FileExtension
    if Job::FitsFileExtensionBatch.create_for(current_user, @file_extension)
      flash[:notice] = "FITS batch scheduled for extension '#{@file_extension.extension}'"
    else
      flash[:notice] = "There is already a FITS batch scheduled for extension '#{@file_extension.extension}'"
    end
    redirect_to :back
  end

  def random_cfs_file
    redirect_to @file_extension.random_cfs_file(params.slice(:repository_id, :virtual_repository_id))
  end

  protected

  def find_file_extension
    @file_extension = FileExtension.find(params[:id])
  end

end