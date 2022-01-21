# frozen_string_literal: true

LOCAL_ENDPOINT = "http://localhost:9324"

require "singleton"

class QueueManager
  include Singleton
  attr_accessor :sqs_client

  def initialize
    self.sqs_client = if Settings.aws.queue_mode == "local"
                        local_client
                      else
                        cloud_client
                      end
  end

  def local_client
    Aws::SQS::Client.new(
      endpoint: LOCAL_ENDPOINT,
      region:   Settings.aws.region #required but not used since endpoint is specified
    )
  end

  def cloud_client
    Aws::SQS::Client.new(
      region: Settings.aws.region
    )
  end

end