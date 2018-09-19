class EventsController < ApplicationController

  before_action :require_medusa_user
  helper_method :eventable_events_path

  autocomplete :user, :email

  def index
    @events = Event.order(updated_at: :desc).page(params[:page]).per_page(params[:per_page] || 25)
  end

  def create
    klass = Kernel.const_get(params[:eventable_type])
    eventable = klass.find(params[:eventable_id])
    authorize! :create_event, eventable
    event = eventable.events.create(allowed_params)
    if event.valid?
      if request.xhr?
        respond_to {|format| format.js}
      else
        redirect_back(fallback_location: root_path)
      end
    else
      @errors = event.errors.full_messages.join('\n')
      if request.xhr?
        respond_to {|format| format.js}
      else
        flash[:notice] = 'Invalid event parameters: \n' + @errors
        redirect_back(fallback_location: root_path)
      end
    end
  end

  protected

  def allowed_params
    params[:event].permit(:eventable, :key, :note, :actor_email, :date)
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def eventable_events_path(event)
    eventable = event.eventable
    self.send("events_#{eventable.class.to_s.underscore}_path", eventable)
  end

end