class EventsController < ApplicationController
  autocomplete :user, :uid

  def create
    klass = Kernel.const_get(params[:eventable_type])
    eventable = klass.find(params[:eventable_id])
    eventable.events.create(allowed_params)
    if request.xhr?
      respond_to {|format| format.js}
    else
      redirect_to eventable
    end
  end

  protected

  def allowed_params
    params[:event].permit(:eventable, :key, :note, :actor_netid, :date)
  end

end