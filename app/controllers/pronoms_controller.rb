class PronomsController < ApplicationController

  before_action :require_medusa_user, except: :show

  def destroy
    @pronom = Pronom.find(params[:id])
    authorize! :update, @pronom.file_format
    @pronom.destroy!
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      redirect_to @pronom.file_format
    end
  end

  def new
    @file_format = FileFormat.find(params[:file_format_id])
    authorize! :update, @file_format
    @pronom = Pronom.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @file_format = FileFormat.find(params[:file_format_id])
    authorize! :update, @file_format
    @pronom = @file_format.pronoms.build(allowed_pronom_params)
    @created = @pronom.save
    respond_to do |format|
      format.js
    end
  end

  def edit
    @pronom = Pronom.find(params[:id])
    authorize! :update, @pronom.file_format
    respond_to do |format|
      format.js
    end
  end

  def update
    @pronom = Pronom.find(params[:id])
    authorize! :update, @pronom.file_format
    @updated = @pronom.update_attributes(allowed_pronom_params)
    respond_to do |format|
      format.js
    end
  end

  protected

  def allowed_pronom_params
    params[:pronom].permit(:pronom_id, :version)
  end

end