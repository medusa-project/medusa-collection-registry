class AttachmentsController < ApplicationController

  before_filter :find_attachment_and_attachable, :only => [:destroy, :show, :edit, :update,:download]

  def destroy
    @attachment.destroy
    redirect_to @attachable
  end

  def show

  end

  def edit

  end

  def update
    #we should not need to set description sepratately. There is some issue with mass assignment, that is why this hack
    desc = params[:attachment].delete(:description)
    @attachment.description = desc
    if @attachment.update_attributes(params[:attachment])
      redirect_to collection_path(@attachment.attachable_id)
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
    @attachment = Attachment.new
    @attachment.author = Person.find_or_create_by_net_id(current_user.uid)
    @attachment.attachable = @attachable
  end

  def create
    klass = attachable_class(params[:attachment])
    @attachable = klass.find(params[:attachment].delete(:attachable_id))
    #we should not need to set description sepratately. There is some issue with mass assignment, that is why this hack
    desc = params[:attachment].delete(:description)
    @attachment = Attachment.new(params[:attachment])
    @attachment.description = desc
    @attachment.attachable = @attachable
    if @attachment.save
      redirect_to collection_path(@attachment.attachable_id)
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
      else
        raise RuntimeError, 'Unrecognized attachable type'
    end
  end

end
