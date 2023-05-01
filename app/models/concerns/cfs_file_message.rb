require 'active_support/concern'

module CfsFileMessage
  extend ActiveSupport::Concern

  included do
    delegate :incoming_queue, to: :class
  end

  module ClassMethods
    def incoming_queue
      Settings.message_queues.fixity_to_medusa_url
    end
  end

  def on_fixity_success(response)
    if response.found?
      if response.md5.present?
        incoming_md5 = response.md5
        if incoming_md5 == self.md5_sum
          self.update_fixity_status_ok
        else
          self.update_fixity_status_bad_with_event
        end
      end
    else
      self.update_fixity_status_not_found_with_event
    end
  end

  def on_fixity_failure(response)
    Rails.logger.error "Fixity request failed for Cfs File id: #{self.id}"
  end

  def on_fixity_unrecognized(response)
    Rails.logger.error "Fixity request response unrecognized for Cfs File id: #{self.id}"
  end

end