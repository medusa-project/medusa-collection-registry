#To be used in the test environment to fake the Amazon Glacier server without having to
#upload to amazon or wait.
require 'singleton'

module Test
  class AmazonGlacierServer
    include Singleton

    attr_accessor :outgoing_queue, :incoming_queue, :connection

    def initialize
      #note that these are reversed because the config is from the perspective of the app, not the glacier server
      self.incoming_queue = MedusaRails3::Application.medusa_config['amazon']['outgoing_queue']
      self.outgoing_queue = MedusaRails3::Application.medusa_config['amazon']['incoming_queue']
      self.connection = Bunny.new
      connection.start
    end

    def clear_queues
      [self.incoming_queue, self.outgoing_queue].each do |queue_name|
        continue = true
        while continue
          with_message(queue_name) do |message|
            continue = message
            puts "#{self.class} clearing: #{message} from: #{queue_name}" if message
          end
        end
      end
    end

    def import_succeed
      with_parsed_message(self.incoming_queue) do |message|
        return_message = {pass_through: message['pass_through'], status: 'success',
                          parameters: {archive_id: UUID.generate}}
        puts "Sending message: #{}"
        send_message(self.outgoing_queue, return_message)
      end
    end

    def import_fail
      with_parsed_message(self.incoming_queue) do |message|
        return_message = {pass_through: message['pass_through'], status: 'failure', error_message: 'test_error'}
        send_message(self.outgoing_queue, return_message)
      end
    end

    protected

    def with_channel
      channel = connection.create_channel
      yield channel
    ensure
      channel.close
    end

    def with_queue(queue_name)
      with_channel do |channel|
        queue = channel.queue(queue_name, durable: true)
        yield queue
      end
    end

    def with_message(queue_name)
      with_queue(queue_name) do |queue|
        delivery_info, properties, raw_payload = queue.pop
        yield raw_payload
      end
    end

    def with_parsed_message(queue_name)
      with_message(queue_name) do |message|
        json_message = message ? JSON.parse(message) : nil
        yield json_message
      end
    end

    def with_exchange
      with_channel do |channel|
        exchange = channel.default_exchange
        yield exchange
      end
    end

    def send_message(queue_name, message)
      with_exchange do |exchange|
        message = message.to_json if message.is_a?(Hash)
        exchange.publish(message, routing_key: queue_name, persistent: true)
      end
    end

  end
end