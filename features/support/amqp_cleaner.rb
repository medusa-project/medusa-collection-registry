#before each test mock the amqp queues
Before do
  AmqpHelper::Connector.mock_all
end
