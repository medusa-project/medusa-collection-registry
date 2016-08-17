class FileFormatNormalizationPathsController < ApplicationController

  before_action :require_medusa_user, except: :show

  def destroy
    @normalization_path = FileFormatNormalizationPath.find(params[:id])
    authorize! :update, @normalization_path.file_format
    @normalization_path.destroy!
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      redirect_to @normalization_path.file_format
    end
  end

  def new
    @file_format = FileFormat.find(params[:file_format_id])
    authorize! :update, @file_format
    @normalization_path = FileFormatNormalizationPath.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @file_format = FileFormat.find(params[:file_format_id])
    authorize! :update, @file_format
    @normalization_path = @file_format.file_format_normalization_paths.build(allowed_normalization_path_params)
    @created = @normalization_path.save
    respond_to do |format|
      format.js
    end
  end

  def edit
    @normalization_path = FileFormatNormalizationPath.find(params[:id])
    authorize! :update, @normalization_path.file_format
    respond_to do |format|
      format.js
    end
  end

  def update
    @normalization_path = FileFormatNormalizationPath.find(params[:id])
    authorize! :update, @normalization_path.file_format
    @updated = @normalization_path.update_attributes(allowed_normalization_path_params)
    respond_to do |format|
      format.js
    end
  end

  def show
    @normalization_path = FileFormatNormalizationPath.find(params[:id])
  end

  protected

  def allowed_normalization_path_params
    params[:file_format_normalization_path].permit(:name, :output_format_id, :software, :software_version,
                                                   :operating_system, :software_settings, :potential_for_loss)
  end

end