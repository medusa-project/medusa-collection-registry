#Represent AMQP connection and provide convenience methods.
#The amqp section of medusa.yml can contain any option appropriate for Bunny.new.
require 'set'

class AmqpConnector < Object

  cattr_accessor :connectors
  attr_accessor :connection, :known_queues, :config

  def initialize(key, config)
    self.class.connectors ||= Hash.new
    self.class.connectors[key] = self
    self.config = config.merge!(recover_from_connection_close: true)
    self.reinitialize
  end

  def self.connector(key)
    self.connectors[key]
  end

  def reinitialize
    #config = Application.medusa_config.amqp(default: {}).symbolize_keys
    self.known_queues = Set.new
    self.connection.close if self.connection
    self.connection = Bunny.new(config)
    self.connection.start
  end

  def self.clear_all_queues
    self.connectors.values.each {|connector| connector.clear_all_queues}
  end

  def clear_all_queues
    self.clear_queues(*self.known_queues.to_a)
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

  def ensure_queue(queue_name)
    unless self.known_queues.include?(queue_name)
      with_queue(queue_name) do |queue|
        #no-op, just ensuring queue exists
      end
      self.known_queues << queue_name
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
    ensure_queue(queue_name)
    with_exchange do |exchange|
      message = message.to_json if message.is_a?(Hash)
      exchange.publish(message, routing_key: queue_name, persistent: true)
    end
  end

end