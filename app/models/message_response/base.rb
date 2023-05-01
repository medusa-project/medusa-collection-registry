#base class for common functionality
#implement the indicated methods in a subclass, the handlers in the
#class that will handle the response, and then call the class
#method handle_responses to take messages off the queue and handle them.
class MessageResponse::Base < Object

  attr_accessor :payload

  def initialize(raw_payload:)
    self.payload = JSON.parse(raw_payload)
  end

  def status
    self.payload['status']
  end

  def action
    self.payload['action']
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

  #redundant except for testing
  def self.handle_responses

    sqs = QueueManager.instance.sqs_client
    Rails.logger.warn "handle response #{self.incoming_queue}"
    Rails.logger.warn "incoming queue: #{self.incoming_queue}"

    response = sqs.receive_message(queue_url: self.incoming_queue, max_number_of_messages: 1)
    return nil if response.data.messages.count.zero?

    while response.data.messages.count.positive? do
      raw_payload = response.data.messages[0].body
      break unless raw_payload

      sqs.delete_message({queue_url: self.incoming_queue, receipt_handle: response.data.messages[0].receipt_handle})
      handle_response(raw_payload: raw_payload)
      response = sqs.receive_message(queue_url: self.incoming_queue, max_number_of_messages: 1)
    end
  end

  def self.handle_response(raw_payload:)
    response = self.new(raw_payload: raw_payload)
    response.dispatch_result
  end

  #The key in the pass through hash used to find the class of the
  # object to handle the response
  def pass_through_class_key
    raise RuntimeError, 'Subclass Responsibility'
  end

  #The key in the pass through hash used to find the id of the
  # object to handle the response
  def pass_through_id_key
    raise RuntimeError, 'Subclass Responsibility'
  end

  #AMQP queue from which to pull messages
  def self.incoming_queue
    raise RuntimeError, 'Subclass Responsibility'
  end

  #Name to use for listener logging
  def self.listener_name
    raise RuntimeError, 'Subclass Responsibility'
  end

  #method to call on handler object when message indicates success. Called
  #with sole argument this response object
  def success_method
    raise RuntimeError, 'Subclass Responsibility'
  end

  #method to call on handler object when message indicates failure. Called
  #with sole argument this response object
  def failure_method
    raise RuntimeError, 'Subclass Responsibility'
  end

  #method to call on handler object when message status is neither
  # success nor failure (should not happen). Called
  #with sole argument this response object
  def unrecognized_method
    raise RuntimeError, 'Subclass Responsibility'
  end

end