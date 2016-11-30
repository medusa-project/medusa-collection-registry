require 'fileutils'

#before each test make sure that the amazon AMQP queues are clean
Before do
  AmqpHelper::Connector.mock_all
end
