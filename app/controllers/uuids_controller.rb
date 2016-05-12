class UuidsController < ApplicationController

  def show
    uuid = MedusaUuid.find_by(uuid: params[:id])
    unless uuid.present? and uuid.uuidable.present?
      @unfound_uuid = params[:id]
      render 'not_found', status: 404
      return
    end
    object = uuid.uuidable
    if (current_user and can?(:read, object)) or request.env['HTTP_AUTHORIZATION'].present?
        redirect_to polymorphic_path(object, params.slice(:format))
    else
        redirect_to public_path_to(object)
    end

  end

end