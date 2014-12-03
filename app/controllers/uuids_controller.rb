class UuidsController < ApplicationController

  def show
    uuid = MedusaUuid.find_by(uuid: params[:id])
    unless uuid.present? and uuid.uuidable.present?
      @unfound_uuid = params[:id]
      render 'not_found', status: 404
      return
    end
    object = uuid.uuidable
    if current_user and can?(:read, object)
        redirect_to object
    else
        redirect_to public_path(object)
    end

  end

end