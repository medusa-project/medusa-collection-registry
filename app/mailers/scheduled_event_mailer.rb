class ScheduledEventMailer < ActionMailer::Base
  default from: "medusa-noreply@#{self.smtp_settings['domain'].if_blank('library.illinois.edu')}"

  def reminder(event)
    @event = event
    @eventable = event.scheduled_eventable
    mail(to: event.actor_netid, subject: 'Medusa scheduled event reminder')
  end
end
