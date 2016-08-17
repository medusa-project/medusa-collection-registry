class FileFormatNotesController < ApplicationController

  before_action :require_medusa_user

  def destroy
    @note = FileFormatNote.find(params[:id])
    authorize! :update, @note.file_format
    @note.destroy!
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      redirect_to @note.file_format
    end
  end

  def new
    @file_format = FileFormat.find(params[:file_format_id])
    authorize! :update, @file_format
    @note = FileFormatNote.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @file_format = FileFormat.find(params[:file_format_id])
    authorize! :update, @file_format
    @note = @file_format.file_format_notes.build(allowed_note_params)
    @note.user = current_user
    @note.date = Date.today
    @created = @note.save
    respond_to do |format|
      format.js
    end
  end

  def edit
    @note = FileFormatNote.find(params[:id])
    authorize! :update, @note.file_format
    respond_to do |format|
      format.js
    end
  end

  def update
    @note = FileFormatNote.find(params[:id])
    authorize! :update, @note.file_format
    @updated = @note.update_attributes(allowed_note_params)
    respond_to do |format|
      format.js
    end
  end


  protected

  def allowed_note_params
    params[:file_format_note].permit(:note)
  end

end