#Represent AMQP connection and provide convenience methods.
#The amqp section of medusa.yml can contain any option appropriate for Bunny.new.
require 'singleton'

class AmqpConnector < Object
  include Singleton

  attr_accessor :connection

  def initialize
    config = (MedusaRails3::Application.medusa_config['amqp'] || {}).symbolize_keys
    self.connection = Bunny.new(config)
    self.connection.start
  end

  def clear_queues(*queue_names)
    queue_names.each do |queue_name|
      continue = true
      while continue
        with_message(queue_name) do |message|
          continue = message
          puts "#{self.class} clearing: #{message} from: #{queue_name}" if message
        end
      end
    end
  end

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