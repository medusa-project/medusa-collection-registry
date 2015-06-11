require 'active_support/concern'

module CfsFileAmqp
  extend ActiveSupport::Concern

  included do
    delegate :incoming_queue, :outgoing_queue, to: :class
  end

  module ClassMethods
    def incoming_queue
      MedusaCollectionRegistry::Application.medusa_config['fixity_server']['incoming_queue']
    end

    def outgoing_queue
      MedusaCollectionRegistry::Application.medusa_config['fixity_server']['outgoing_queue']
    end

  end

  def send_amqp_fixity_message
    AmqpConnector.instance.send_message(self.outgoing_queue, create_amqp_fixity_message)
  end

  def create_amqp_fixity_message
    {action: :file_fixity,
     parameters: {path: self.relative_path, algorithms: [:md5]},
     pass_through: {cfs_file_id: self.id, cfs_file_class: self.class.to_s}}
  end

  def on_amqp_fixity_success(response)
    if response.md5.present?
      self.md5_sum = response.md5
      self.save!
    end
  end

  def on_amqp_fixity_failure(response)
    Rails.logger.error "Fixity request failed for Cfs File id: #{self.id}"
  end

  def on_amqp_fixity_unrecognized(response)
    Rails.logger.error "Fixity request response unrecognized for Cfs File id: #{self.id}"
  end

end