namespace :client do
  desc "handle requests from active amqp accruers"
  task fetch_client_messages: :environment do
    AmqpAccrual::Config.clients.each do |client|
      AmqpAccrual::Receiver.handle_responses(client)
    end
  end
end

