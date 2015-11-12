module Idb
  class AmqpReceiver < Object

    def self.handle_responses
      AmqpConnector.instance.with_queue(Config.instance.incoming_queue) do |queue|
        while true
          delivery_info, properties, raw_payload = queue.pop
          break unless raw_payload
          handle_message(JSON.parse(raw_payload))
        end
      end
    end

    def self.handle_message(message)
      case message['operation']
        when 'ingest'
          Idb::IngestJob.create_for(message)
        else
          raise RuntimeError, "Unrecognized operation requested"
      end
    end

  end
end