class MedusaBaseMailer < ActionMailer::Base

  delegate :feedback_address, :dev_address, :no_reply_address, :admin_address, to: :class

  def self.feedback_address
    Application.medusa_config.feedback_email
  end

  def self.dev_address
    Application.medusa_config.dev_email
  end

  def self.no_reply_address
    Application.medusa_config.noreply_email
  end

  def self.admin_address
    Application.medusa_config.admin_email
  end

  default from: self.no_reply_address

end