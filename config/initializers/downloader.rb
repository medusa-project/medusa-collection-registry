require_relative 'config'

amqp_settings = Settings.downloader.amqp
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      AmqpHelper::Connector.new(:downloader, amqp_settings)
    end
  end
else
  AmqpHelper::Connector.new(:downloader, amqp_settings)
end