require 'active_support/concern'

module CfsFileAmqp
  extend ActiveSupport::Concern

  included do
    delegate :incoming_queue, :outgoing_queue, to: :class
  end

  module ClassMethods
    def incoming_queue
      Settings.medusa.fixity_server.incoming_queue
    end

    def outgoing_queue
      Settings.medusa.fixity_server.outgoing_queue
    end

  end

  def send_amqp_fixity_message
    AmqpHelper::Connector[:medusa].send_message(self.outgoing_queue, create_amqp_fixity_message)
  end

  def create_amqp_fixity_message
    {action: :file_fixity,
     parameters: {path: self.relative_path, algorithms: [:md5]},
     pass_through: {cfs_file_id: self.id, cfs_file_class: self.class.to_s}}
  end

  def on_amqp_fixity_success(response)
    if response.found?
      if response.md5.present?
        incoming_md5 = response.md5
        if incoming_md5 == self.md5_sum
          self.update_fixity_status_ok_with_event
        else
          self.update_fixity_status_bad_with_event
        end
      end
    else
      self.update_fixity_status_not_found_with_event
    end
  end

  def on_amqp_fixity_failure(response)
    Rails.logger.error "Fixity request failed for Cfs File id: #{self.id}"
  end

  def on_amqp_fixity_unrecognized(response)
    Rails.logger.error "Fixity request response unrecognized for Cfs File id: #{self.id}"
  end

end