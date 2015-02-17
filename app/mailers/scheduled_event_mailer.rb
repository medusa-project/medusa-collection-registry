class ScheduledEventMailer < MedusaBaseMailer

  def reminder(event)
    @event = event
    @eventable = event.scheduled_eventable
    mail(to: event.actor_email, subject: 'Medusa scheduled event reminder')
  end
end
