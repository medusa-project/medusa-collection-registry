class EventsController < ApplicationController
  autocomplete :user, :uid

  def create
    klass = Kernel.const_get(params[:eventable_type])
    eventable = klass.find(params[:eventable_id])
    eventable.events.create(params[:event])
    if request.xhr?
      respond_to {|format| format.js}
    else
      redirect_to eventable
    end
  end

end