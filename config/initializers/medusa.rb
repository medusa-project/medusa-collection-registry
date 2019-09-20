require_relative 'config'

MedusaCollectionRegistry::Application.medusa_host = Settings.medusa_host

amqp_settings = Settings.medusa.amqp
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      AmqpHelper::Connector.new(:medusa, amqp_settings)
    end
  end
else
  AmqpHelper::Connector.new(:medusa, amqp_settings)
end
