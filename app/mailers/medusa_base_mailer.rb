class MedusaBaseMailer < ApplicationMailer

  delegate :feedback_address, :dev_address, :no_reply_address, :admin_address, to: :class

  def self.feedback_address
    Settings.medusa.email.feedback
  end

  def self.dev_address
    Settings.medusa.email.dev
  end

  def self.no_reply_address
    Settings.medusa.email.noreply
  end

  def self.admin_address
    Settings.medusa.email.admin
  end

  def subject(string)
    "#{subject_prefix}: #{string}"
  end

  def subject_prefix
    if Settings&.mailer&.system_name
      "Medusa [#{Settings.mailer.system_name}]"
    else
      "Medusa"
    end
  end

  default from: self.no_reply_address

end