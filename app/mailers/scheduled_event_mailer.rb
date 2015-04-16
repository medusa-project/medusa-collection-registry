class ScheduledEventMailer < MedusaBaseMailer

  def reminder(event)
    @event = event
    @eventable = event.scheduled_eventable.decorate
    mail(to: event.actor_email, subject: 'Medusa scheduled event reminder')
  end
end
