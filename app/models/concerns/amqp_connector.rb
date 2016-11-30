require 'active_support/concern'

module AmqpConnector
  extend ActiveSupport::Concern

  included do
    delegate :amqp_connector, to: :class
    class_attribute :connector
  end

  module ClassMethods

    def use_amqp_connector(key)
      self.connector = key
    end

    def amqp_connector
      AmqpHelper::Connector[self.connector]
    end

  end

end