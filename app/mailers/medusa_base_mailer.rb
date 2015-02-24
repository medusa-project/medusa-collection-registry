class MedusaBaseMailer < ActionMailer::Base

  def self.feedback_address
    MedusaCollectionRegistry::Application.medusa_config['email']['feedback']
  end

  def self.dev_address
    MedusaCollectionRegistry::Application.medusa_config['email']['dev']
  end

  def self.no_reply_address
    MedusaCollectionRegistry::Application.medusa_config['email']['noreply']
  end

  default from: self.no_reply_address

  protected

  def feedback_address
    self.class.feedback_address
  end

  def dev_address
    self.class.dev_address
  end

end