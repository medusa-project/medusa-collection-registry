module AmqpAccrual
  class Receiver < Object

    def self.listen
      AmqpListener.new(amqp_config: AmqpConnector.connector(:medusa).config,
                       name: 'idb',
                       queue_name: Idb::Config.instance.incoming_queue,
                       action_callback: ->(payload) { self.handle_message(payload) }).listen
    end

    def self.handle_message(payload)
      message = JSON.parse(payload)
      case message['operation']
        when 'ingest'
          Idb::IngestJob.create_for(message)
        else
          raise RuntimeError, "Unrecognized operation requested"
      end
    rescue Exception
      Rails.logger.error "Failed to create IDB Ingest Job for message: #{message}"
      raise
    end

    #redundant except for tests
    def self.handle_responses
      AmqpConnector.connector(:medusa).with_queue(Config.instance.incoming_queue) do |queue|
        while true
          delivery_info, properties, raw_payload = queue.pop
          break unless raw_payload
          handle_message(raw_payload)
        end
      end
    end

  end
end