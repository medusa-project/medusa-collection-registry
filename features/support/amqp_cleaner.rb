require 'fileutils'

#before each test make sure that the amazon AMQP queues are clean
Before do
  AmqpConnector.clear_all_queues
end

