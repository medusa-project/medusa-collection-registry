require 'active_support/concern'

module FileFormatNormalizationPathsActions
  extend ActiveSupport::Concern

  def delete_normalization_path
    @file_format = FileFormat.find(params[:id])
    @normalization_path = FileFormatNormalizationPath.find(params[:normalization_path_id])
    render :nothing and return unless @normalization_path.file_format = @file_format
    authorize! :update, @file_format
    @normalization_path.destroy!
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      redirect_to @file_format
    end
  end

  def new_normalization_path
    @file_format = FileFormat.find(params[:id])
    authorize! :upddate, @file_format
    @normalization_path = FileFormatNormalizationPath.new
    respond_to do |format|
      format.js
    end
  end

  def create_normalization_path
    @file_format = FileFormat.find(params[:id])
    authorize! :update, @file_format
    @normalization_path = @file_format.file_format_normalization_paths.build(allowed_normalization_path_params)
    @created = @normalization_path.save
    respond_to do |format|
      format.js
    end
  end

  def edit_normalization_path
    @file_format = FileFormat.find(params[:id])
    @normalization_path = FileFormatNormalizationPath.find(params[:normalization_path_id])
    render :nothing and return unless @normalization_path.file_format = @file_format
    authorize! :update, @file_format
    respond_to do |format|
      format.js
    end
  end

  def update_normalization_path
    @file_format = FileFormat.find(params[:id])
    @normalization_path = FileFormatNormalizationPath.find(params[:normalization_path_id])
    render :nothing and return unless @normalization_path.file_format = @file_format
    authorize! :update, @file_format
    @updated = @normalization_path.update_attributes(allowed_normalization_path_params)
    respond_to do |format|
      format.js
    end
  end

  def normalization_path
    @file_format = FileFormat.find(params[:id])
    @normalization_path = FileFormatNormalizationPath.find(params[:normalization_path_id])
  end

  protected

  def allowed_normalization_path_params
    params[:file_format_normalization_path].permit(:name, :output_format_id, :software, :software_version,
                                                   :operating_system, :software_settings, :potential_for_loss)
  end

end