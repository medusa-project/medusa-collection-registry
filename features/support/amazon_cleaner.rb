require 'fileutils'

#before each test make sure that the amazon AMQP queues are clean
Before do
  Test::AmazonGlacierServer.instance.clear_queues
end

