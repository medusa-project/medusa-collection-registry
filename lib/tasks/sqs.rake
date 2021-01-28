require "aws-sdk-sqs"

namespace :sqs do
  desc 'hello'
  task hello: :environment do
    print "hello"
  end
  desc 'list local queues'
  task list_local_queues: :environment do
    sqs = Aws::SQS::Client.new(region: "us-east-2", endpoint: "http://localhost:9324")
    puts sqs.list_queues
  end
end