class ScheduledEventsController < ApplicationController

  before_filter :require_logged_in
  before_filter :find_scheduled_event, :only => [:cancel, :complete, :edit, :update, :destroy]

  def create
    authorize! :create, ScheduledEvent
    klass = Kernel.const_get(params[:scheduled_eventable_type])
    eventable = klass.find(params[:scheduled_eventable_id])
    event = eventable.scheduled_events.create(allowed_params)
    event.enqueue_initial
    if request.xhr?
      respond_to {|format| format.js}
    else
      redirect_to eventable
    end
  end

  def cancel
    authorize! :update, @scheduled_event
    @scheduled_event.be_cancelled
    redirect_to params[:return_to]
  end

  def complete
    authorize! :update, @scheduled_event
    @scheduled_event.be_complete(current_user)
    redirect_to params[:return_to]
  end

  def edit
    authorize! :update, @scheduled_event
    @return_to = params[:return_to]
    x = 1
  end

  def update
    authorize! :update, @scheduled_event
    return_to = params[:scheduled_event].delete(:return_to)
    if @scheduled_event.update_attributes(params[:scheduled_event].permit(:actor_netid, :action_date, :state, :key))
      redirect_to return_to
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @scheduled_event
    @scheduled_event.destroy
    redirect_to params[:return_to]
  end

  protected

  def find_scheduled_event
    @scheduled_event = ScheduledEvent.find(params[:id])
  end

  def allowed_params
    params[:scheduled_event].permit(:action_date, :actor_netid, :key, :note, :scheduled_eventable_id, :scheduled_eventable_type, :state)
  end
end