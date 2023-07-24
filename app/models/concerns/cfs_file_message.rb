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
    begin
      response_found = response.found?
      response_found = false if response_found == "false"
      return self.update_fixity_status_not_found_with_event unless response_found

      return self.update_fixity_status_bad_with_event unless response.md5.present?

      return self.update_fixity_status_bad_with_event(md5sum: response.md5) unless response.md5 == self.md5_sum

      self.update_fixity_status_ok

    rescue StandardError
      Rails.logger.warn "on_fixity_success error for CfsFile #{self.id}, message: #{response}"
    end
  end

  def on_fixity_failure(response)
    Rails.logger.error "Fixity request failed for CfsFile: #{self.id}, #{response}"
  end

  def on_fixity_unrecognized(response)
    Rails.logger.error "Fixity request response unrecognized for CfsFile: #{self.id}, #{response}"
  end

end