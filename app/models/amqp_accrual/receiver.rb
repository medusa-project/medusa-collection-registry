module AmqpAccrual
  class Receiver < Object

    def self.listen(client)
      AmqpListener.new(amqp_config: AmqpConnector.connector(:medusa).config,
                       name: client,
                       queue_name: AmqpAccrual::Config.incoming_queue(client),
                       action_callback: ->(payload) { self.handle_message(client, payload) }).listen
    end

    def self.handle_message(client, payload)
      message = JSON.parse(payload)
      case message['operation']
        when 'ingest'
          AmqpAccrual::IngestJob.create_for(client, message)
        when 'delete'
          AmqpAccrual::DeleteJob.create_for(client, message)
        else
          raise RuntimeError, 'Unrecognized operation requested'
      end
    rescue Exception
      Rails.logger.error "Failed to create Amqp Accrual Job for client: #{client} message: #{message}"
      raise
    end

    #redundant except for tests
    def self.handle_responses(client)
      AmqpConnector.connector(:medusa).with_queue(AmqpAccrual::Config.incoming_queue(client)) do |queue|
        while true
          delivery_info, properties, raw_payload = queue.pop
          break unless raw_payload
          handle_message(client, raw_payload)
        end
      end
    end

  end
end