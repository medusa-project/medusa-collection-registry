class AttachmentsController < ApplicationController

  before_filter :require_logged_in
  before_filter :find_attachment_and_attachable, :only => [:destroy, :show, :edit, :update,:download]

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

  def update
    authorize! :update_attachment, @attachable
    #we should not need to set description separately. There is some issue with mass assignment, that is why this hack
    desc = params[:attachment].delete(:description)
    @attachment.description = desc
    @attachment.attachment = params[:attachment][:attachment] if params[:attachment][:attachment]
    if @attachment.save
      x = polymorphic_path(@attachable)
      redirect_to polymorphic_path(@attachable)
    else
      render 'edit'
    end
  end

  def download
    @attachment = Attachment.find(params[:id])
    send_file(@attachment.attachment.path, :disposition => 'inline')
  end

  def new
    klass = attachable_class(params)
    @attachable = klass.find(params[:attachable_id])
    authorize! :create_attachment, @attachable
    @attachment = Attachment.new
    @attachment.author = Person.find_or_create_by(net_id: current_user.uid)
    @attachment.attachable = @attachable
  end

  def create
    klass = attachable_class(params[:attachment])
    @attachable = klass.find(params[:attachment].delete(:attachable_id))
    authorize! :create_attachment, @attachable
    #we should not need to set description separately. There is some issue with mass assignment, that is why this hack
    desc = params[:attachment].delete(:description)
    @attachment = Attachment.new(allowed_params)
    @attachment.description = desc
    @attachment.attachable = @attachable
    @attachment.author_id = current_user.id
    if params[:attachment].present? and @attachment.save
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
    params[:attachment].permit(:attachable_id, :attachable_type, :attachment_content_type,
                               :attachment_file_name, :attachment_file_size, :attachment)
  end

end
