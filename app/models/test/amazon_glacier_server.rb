#To be used in the test environment to fake the Amazon Glacier server without having to
#upload to amazon or wait.
require 'singleton'

module Test
  class AmazonGlacierServer
    include Singleton
    include AmqpConnector
    use_amqp_connector :medusa

    attr_accessor :outgoing_queue, :incoming_queue

    def initialize
      #note that these are reversed because the config is from the perspective of the app, not the glacier server
      self.incoming_queue = Settings.medusa.amazon.outgoing_queue
      self.outgoing_queue = Settings.medusa.amazon.incoming_queue
    end

    def import_succeed
      amqp_connector.with_parsed_message(self.incoming_queue) do |message|
        return_message = {pass_through: message['pass_through'], status: 'success',
                          parameters: {archive_ids: [UUID.generate]}, action: 'upload_directory'}
        amqp_connector.send_message(self.outgoing_queue, return_message)
      end
    end

    def import_fail
      amqp_connector.with_parsed_message(self.incoming_queue) do |message|
        return_message = {pass_through: message['pass_through'], status: 'failure', message: 'test_error', action: 'upload_directory'}
        amqp_connector.send_message(self.outgoing_queue, return_message)
      end
    end

  end
end