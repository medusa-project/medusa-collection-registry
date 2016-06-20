class UuidsController < ApplicationController

  def show
    uuid = MedusaUuid.find_by(uuid: params[:id])
    unless uuid.present? and uuid.uuidable.present?
      @unfound_uuid = params[:id]
      respond_to do |format|
        format.html {render 'not_found', status: 404}
        format.json {render json: "UUID not found: #{@unfound_uuid}", status: 404}
      end
      return
    end
    object = uuid.uuidable
    redirect_to polymorphic_path(object, params.slice(:format))
  end

end