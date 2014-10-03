class EventsController < ApplicationController

  autocomplete :user, :email
  before_filter :require_logged_in

  def create
    klass = Kernel.const_get(params[:eventable_type])
    eventable = klass.find(params[:eventable_id])
    authorize! :create_event, eventable
    event = eventable.events.create(allowed_params)
    if event.valid?
      if request.xhr?
        respond_to { |format| format.js }
      else
        redirect_to :back
      end
    else
      @errors = event.errors.full_messages.join('\n')
      if request.xhr?
        respond_to {|format| format.js}
      else
        flash[:notice] = 'Invalid event parameters: \n' + @errors
        redirect_to :back
      end
    end
  end

  def destroy
    event = Event.find(params[:id])
    authorize! :delete_event, event.eventable
    event.destroy!
    #redirect_to self.send("events_#{event.eventable.class.to_s.underscore}_path", event.eventable)
    redirect_to :back
  end

  protected

  def allowed_params
    params[:event].permit(:eventable, :key, :note, :actor_email, :date)
  end

end