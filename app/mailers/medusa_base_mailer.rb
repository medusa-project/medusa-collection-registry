class MedusaBaseMailer < ActionMailer::Base
  default from: "noreply@#{self.smtp_settings['domain'].if_blank('illinois.edu')}"

  protected

  def feedback_address
    MedusaCollectionRegistry::Application.medusa_config['email']['feedback']
  end

  def dev_address
    MedusaCollectionRegistry::Application.medusa_config['email']['dev']
  end

end