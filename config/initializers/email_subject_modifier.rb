#Adds some extra information to email subjects
class EmailSubjectModifier

  def self.delivering_email(message)
    prefix = if system_name = Settings&.mailer&.system_name
               "Medusa[#{system_name}]"
             else
               "Medusa"
             end
    message.subject = "#{prefix}: #{message.subject}"
  end

end

ActionMailer::Base.register_interceptor(EmailSubjectModifier)