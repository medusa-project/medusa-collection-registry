class ScheduledEventMailer < ActionMailer::Base
  default from: "medusa-no-reply@library.illinois.edu"

  def reminder(event)
    @event = event

    mail(to: "#{event.actor_netid}@illinois.edu", subject: 'Medusa scheduled event reminder')
  end
end
