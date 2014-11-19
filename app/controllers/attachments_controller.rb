class AttachmentsController < ApplicationController

  before_filter :require_logged_in
  before_filter :find_attachment_and_attachable, only: [:destroy, :show, :edit, :update, :download]

  def destroy
    authorize! :destroy_attachment, @attachable
    @attachment.destroy
    redirect_to @attachable
  end

  def show

  end

  def edit
    authorize! :update_attachment, @attachable
  end

  #For unknown reasons trying to do this the straightforward way fails. Hence this.
  def update
    authorize! :update_attachment, @attachable
    description = params[:attachment].delete(:description)
    @attachment.description = description
    @attachment.attachment = params[:attachment][:attachment] if params[:attachment][:attachment]
    @attachment.author = current_user.person
    if @attachment.save
      redirect_to polymorphic_path(@attachable)
    else
      render 'edit'
    end
  end

  def download
    @attachment = Attachment.find(params[:id])
    send_file(@attachment.attachment.path, disposition: 'inline')
  end

  def new
    klass = attachable_class(params)
    @attachable = klass.find(params[:attachable_id])
    authorize! :create_attachment, @attachable
    @attachment = Attachment.new(author: current_user.person, attachable: @attachable)
  end

  def create
    klass = attachable_class(params[:attachment])
    @attachable = klass.find(params[:attachment].delete(:attachable_id))
    authorize! :create_attachment, @attachable
    @attachment = Attachment.new(allowed_params)
    @attachment.attachable = @attachable
    @attachment.author ||= current_user.person
    if @attachment.save
      redirect_to polymorphic_path(@attachable)
    else
      render 'new'
    end
  end

  protected

  def find_attachment_and_attachable
    @attachment = Attachment.find(params[:id])
    @attachable = @attachment.attachable
  end

  def attachable_class(hash)
    attachable_type_name = hash.delete(:attachable_type)
    case attachable_type_name
      when 'Collection'
        Collection
      when 'FileGroup', 'ExternalFileGroup', 'ObjectLevelFileGroup', 'BitLevelFileGroup'
        FileGroup
      else
        raise RuntimeError, "Unrecognized attachable type #{attachable_type_name}"
    end
  end

  def allowed_params
    params.require(:attachment).permit(:attachable_id, :attachable_type, :attachment_content_type,
                                       :attachment_file_name, :attachment_file_size, :attachment, :description)
  end

end
