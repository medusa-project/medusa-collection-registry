class AmqpListener

  attr_accessor :amqp_config, :queue_name, :name, :action_callback, :connection
  cattr_accessor :listeners

  def initialize(amqp_config:, queue_name:, name:, action_callback:)
    self.amqp_config = amqp_config
    self.queue_name = queue_name
    self.name = name
    self.action_callback = action_callback
    self.class.listeners ||= Hash.new
    self.class.listeners[self.name] = self
    self.connect
  end

  def connect
    self.connection = Bunny.new(amqp_config)
    self.connection.start
    Kernel.at_exit do
      self.connection.close rescue nil
    end
  end

  def queue
    channel = connection.create_channel
    channel.queue(queue_name, durable: true)
  end

  def listen
    Rails.logger.info "Starting AMQP listener for #{name}"
    queue.subscribe do |delivery_info, properties, payload|
      begin
        action_callback.call(payload)
      rescue Exception => e
        Rails.logger.error "Failed to handle #{name} repsonse #{payload}: #{e}"
      end
    end
  rescue Exception => e
    Rails.logger.error "Unknown error starting AMQP listener for #{name}: #{e}"
  end

end