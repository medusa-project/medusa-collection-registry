module AttachmentsHelper

  def new_attachment_path_for(attachable)
    new_attachment_path(attachable_id: attachable.id, attachable_type: attachable.class.name)
  end

end