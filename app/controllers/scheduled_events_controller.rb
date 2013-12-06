class ScheduledEventsController < ApplicationController
  before_filter :find_scheduled_event, :only => [:cancel, :complete, :edit, :update, :destroy]

  def create
    klass = Kernel.const_get(params[:scheduled_eventable_type])
    eventable = klass.find(params[:scheduled_eventable_id])
    event = eventable.scheduled_events.create(params[:scheduled_event])
    event.enqueue_initial
    if request.xhr?
      respond_to {|format| format.js}
    else
      redirect_to eventable
    end
  end

  def cancel
    @scheduled_event.be_cancelled
    redirect_to params[:return_to]
  end

  def complete
    @scheduled_event.be_complete
    redirect_to params[:return_to]
  end

  def edit
    @return_to = params[:return_to]
    x = 1
  end

  def update
    return_to = params[:scheduled_event].delete(:return_to)
    if @scheduled_event.update_attributes(params[:scheduled_event])
      redirect_to return_to
    else
      render 'edit'
    end
  end

  def destroy
    @scheduled_event.destroy
    redirect_to params[:return_to]
  end

  protected

  def find_scheduled_event
    @scheduled_event = ScheduledEvent.find(params[:id])
  end
end