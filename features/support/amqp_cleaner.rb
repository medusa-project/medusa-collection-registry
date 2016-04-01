require 'fileutils'

#before each test make sure that the amazon AMQP queues are clean
Before do
  AmqpConnector.clear_all_queues
end

#make sure things are cleaned up at the end, too. Sometimes a break in the middle of
#a test can leave things in an incorrect state for the next run
at_exit do
  AmqpConnector.clear_all_queues
end
