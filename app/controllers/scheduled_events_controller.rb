class ScheduledEventsController < ApplicationController
  before_filter :find_scheduled_event, :only => [:cancel, :complete]

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