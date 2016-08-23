require_relative 'config'

amqp_settings = Settings.downloader.amqp.to_h.symbolize_keys
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      AmqpConnector.new(:downloader, amqp_settings)
    end
  end
else
  AmqpConnector.new(:downloader, amqp_settings)
end