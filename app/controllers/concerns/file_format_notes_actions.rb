require 'active_support/concern'

module FileFormatNotesActions
  extend ActiveSupport::Concern

  def delete_note
    @file_format = FileFormat.find(params[:id])
    @note = FileFormatNote.find(params[:note_id])
    render :nothing and return unless @note.file_format = @file_format
    authorize! :update, @file_format
    @note.destroy!
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      redirect_to @file_format
    end
  end

  def new_note
    @file_format = FileFormat.find(params[:id])
    authorize! :update, @file_format
    @note = FileFormatNote.new
    respond_to do |format|
      format.js
    end
  end

  def create_note
    @file_format = FileFormat.find(params[:id])
    authorize! :update, @file_format
    @note = @file_format.file_format_notes.build(allowed_note_params)
    @note.user = current_user
    @note.date = Date.today
    @created = @note.save
    respond_to do |format|
      format.js
    end
  end

  def edit_note
    @file_format = FileFormat.find(params[:id])
    @note = FileFormatNote.find(params[:note_id])
    render :nothing and return unless @note.file_format = @file_format
    authorize! :update, @file_format
    respond_to do |format|
      format.js
    end
  end

  def update_note
    @file_format = FileFormat.find(params[:id])
    @note = FileFormatNote.find(params[:note_id])
    render :nothing and return unless @note.file_format = @file_format
    authorize! :update, @file_format
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