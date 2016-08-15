class FileFormatsController < ApplicationController

  include FileFormatNotesActions
  include FileFormatNormalizationPathsActions

  before_action :require_medusa_user, except: [:show, :index, :normalization_path]
  before_action :get_file_format, only: [:show, :edit, :update, :destroy]

  def index
    @file_formats = FileFormat.order('name asc').all.decorate
  end

  def show

  end

  def edit
    authorize! :update, @file_format
  end

  def update
    authorize! :update, @file_format
    if @file_format.update_attributes(allowed_params)
      redirect_to @file_format
    else
      render 'edit'
    end
  end

  def new
    authorize! :create, FileFormat
    @file_format = FileFormat.new
  end

  def create
    authorize! :create, FileFormat
    @file_format = FileFormat.new(allowed_params)
    if @file_format.save
      redirect_to @file_format
    else
      render 'new'
    end
  end

  def destroy
    authorize! :destroy, @file_format
    if @file_format.destroy
      redirect_to file_formats_path
    else
      redirect_to :back, alert: 'Unable to destroy this file format'
    end
  end

  protected

  def get_file_format
    @file_format = FileFormat.find(params[:id]).decorate
  end

  def allowed_params
    params[:file_format].permit(:name, :pronom_id, :policy_summary, file_format_profile_ids: [])
  end

end