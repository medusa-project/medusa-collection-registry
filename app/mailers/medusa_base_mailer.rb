class MedusaBaseMailer < ActionMailer::Base
  default from: "noreply@#{self.smtp_settings['domain'].if_blank('illinois.edu')}"

  def self.feedback_address
    MedusaCollectionRegistry::Application.medusa_config['email']['feedback']
  end

  def self.dev_address
    MedusaCollectionRegistry::Application.medusa_config['email']['dev']
  end

  protected

  def feedback_address
    self.class.feedback_address
  end

  def dev_address
    self.class.dev_address
  end

end