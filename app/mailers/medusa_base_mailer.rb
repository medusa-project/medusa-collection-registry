class MedusaBaseMailer < ActionMailer::Base

  delegate :feedback_address, :dev_address, :no_reply_address, :admin_address, to: :class

  def self.feedback_address
    MedusaCollectionRegistry::Application.medusa_config['email']['feedback']
  end

  def self.dev_address
    MedusaCollectionRegistry::Application.medusa_config['email']['dev']
  end

  def self.no_reply_address
    MedusaCollectionRegistry::Application.medusa_config['email']['noreply']
  end

  def self.admin_address
    MedusaCollectionRegistry::Application.medusa_config['email']['admin']
  end

  default from: self.no_reply_address

end