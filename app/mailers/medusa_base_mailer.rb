class MedusaBaseMailer < ApplicationMailer

  delegate :feedback_address, :dev_address, :no_reply_address, :admin_address, to: :class

  after_action :add_subject

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
    if system_name = Settings&.mailer&.system_name
      "Medusa[#{system_name}]"
    else
      "Medusa"
    end
  end

  def add_subject
    @subject ||= default_i18n_subject(@subject_args || {})
    mail subject: subject(@subject)
  end

  default from: self.no_reply_address

end