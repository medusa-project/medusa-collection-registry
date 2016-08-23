require_relative 'config'

amqp_settings = Settings.medusa.amqp.to_h.symbolize_keys
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      AmqpConnector.new(:medusa, amqp_settings)
    end
  end
else
  AmqpConnector.new(:medusa, amqp_settings)
end
