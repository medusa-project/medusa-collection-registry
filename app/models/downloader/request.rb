class Downloader::Request < ApplicationRecord

  belongs_to :cfs_directory
  serialize :parameters
  after_initialize :initialize_parameters

  STATUSES = %w(pending request_received request_completed error)
  ALLOWED_ACTIONS = %w(request_received request_completed error)
  validates :status, inclusion: STATUSES, allow_blank: false

  def self.listen
    config = Settings.downloader
    AmqpHelper::Listener.new(amqp_config: config.amqp, name: 'downloader',
                             queue_name: config.incoming_queue,
                             action_callback: ->(payload) {handle_response(payload)}).listen
  end

  def self.handle_response(payload)
    response = JSON.parse(payload)
    request = find_request(response)
    handler = request.find_handler
    if ALLOWED_ACTIONS.include?(response['action'])
      #The send to request updates status information and so on, the same across all types
      #The send to the handler does other work, like emailing about the response
      method = "handle_#{response['action']}"
      request.send(method, response)
      handler.send(method, response) if handler.respond_to?(method)
    else
      Rails.logger.error "Unrecognized response from downloader server: #{response}"
      raise RuntimeError, 'Unrecognized response from downloader server'
    end
  end

  def self.find_request(response)
    if response['client_id'].present?
      response['client_id'].match(/.*_(\d+)/)
      Downloader::Request.find_by(id: $1)
    else
      Downloader::Request.find_by(downloader_id: response['id'])
    end
  end

  def find_handler
    case parameters[:type]
      when 'directory'
        Downloader::DirectoryHandler.new(self)
      else
        Rails.logger.error "Unrecognized downloader request type"
        raise RuntimeError, "Unrecognized downloader request type"
    end
  end

  def self.create_for_directory(cfs_directory, user, recursive: false)
    requeset = self.create!(parameters: {cfs_directory_id: cfs_directory.id, type: 'directory'}, email: user.email, status: 'pending')
    handler = Downloader::DirectoryHandler.new(requeset)
    requeset.send_export_request(handler.export_request_message(recursive: recursive))
  end

  def initialize_parameters
    self.parameters ||= Hash.new
  end

  def handle_request_received(response)
    self.status = 'request_received'
    self.downloader_id = response['id']
    self.save!
  end

  def handle_error(response)
    self.status = 'error'
    self.save!
  end

  def handle_request_completed(response)
    self.status = 'request_completed'
    self.save!
  end

  def send_export_request(message)
    AmqpHelper::Connector[:downloader].send_message(Settings.downloader.outgoing_queue, message)
  end

end
