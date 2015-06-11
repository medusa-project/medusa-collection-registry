#base class for common functionality
#implement the indicated methods in a subclass, the handlers in the
#class that will handle the response, and then call the class
#method handle_responses to take messages off the queue and handle them.
class AmqpResponse::Base < Object

  attr_accessor :payload

  def initialize(amqp_raw_payload)
    self.payload = JSON.parse(amqp_raw_payload)
  end

  def status
    self.payload['status']
  end

  def error_message
    self.payload['message']
  end

  def pass_through(field)
    self.payload['pass_through'][field.to_s]
  end

  def parameter_field(field)
    self.payload['parameters'][field.to_s]
  end

  def handler
    klass = Kernel.const_get(self.pass_through(pass_through_class_key))
    id = self.pass_through(pass_through_id_key)
    klass.find(id)
  end

  def dispatch_result
    case self.status
      when 'success'
        self.handler.send(success_method, self)
      when 'failure'
        self.handler.send(failure_method, self)
      else
        self.handler.send(unrecognized_method, self)
    end
  end

  def self.handle_responses
    AmqpConnector.instance.with_queue(incoming_queue) do |queue|
      while true
        delivery_info, properties, raw_payload = queue.pop
        break unless raw_payload
        response = self.new(raw_payload)
        response.dispatch_result
      end
    end
  end

  #The key in the pass through hash used to find the class of the
  # object to handle the response
  def pass_through_class_key
    raise RuntimeError, "Subclass Responsibility"
  end

  #The key in the pass through hash used to find the id of the
  # object to handle the response
  def pass_through_class_key
    raise RuntimeError, "Subclass Responsibility"
  end

  #AMQP queue from which to pull messages
  def self.incoming_queue
    raise RuntimeError, "Subclass Responsibility"
  end

  #method to call on handler object when message indicates success. Called
  #with sole argument this response object
  def success_method
    raise RuntimeError, "Subclass Responsibility"
  end

  #method to call on handler object when message indicates failure. Called
  #with sole argument this response object
  def failure_method
    raise RuntimeError, "Subclass Responsibility"
  end

  #method to call on handler object when message status is neither
  # success nor failure (should not happen). Called
  #with sole argument this response object
  def unrecognized_method
    raise RuntimeError, "Subclass Responsibility"
  end

end