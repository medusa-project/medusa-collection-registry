class ScheduledEventsController < ApplicationController
  before_filter :find_scheduled_event, :only => [:cancel, :complete]

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

  protected

  def find_scheduled_event
    @scheduled_event = ScheduledEvent.find(params[:id])
  end
end