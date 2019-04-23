#C.f. the email_subject_modifier initializer, which adds the 'system' that the email is coming from
# Note also that we use the i18n facilities to set subjects, so they don't appear here.
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

  default from: self.no_reply_address

end