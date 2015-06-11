require 'active_support/concern'

module AmazonBackupAmqp
  extend ActiveSupport::Concern

  included do
    delegate :incoming_queue, :outgoing_queue, to: :class
  end

  module ClassMethods

  end

end