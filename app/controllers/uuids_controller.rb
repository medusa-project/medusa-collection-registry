class UuidsController < ApplicationController

  def show
    uuid = MedusaUuid.find_by(uuid: params[:id])
    unless uuid.present? and uuid.uuidable.present?
      @unfound_uuid = params[:id]
      render 'not_found', status: 404
      return
    end
    object = uuid.uuidable
    redirect_to polymorphic_path(object, params.slice(:format))
  end

end