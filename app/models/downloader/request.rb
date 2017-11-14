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
      request.send(method, handler, response)
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
      when 'file_list'
        Downloader::FileListHandler.new(self)
      else
        Rails.logger.error "Unrecognized downloader request type"
        raise RuntimeError, "Unrecognized downloader request type"
    end
  end

  def self.create_for_directory(cfs_directory, user, recursive: false)
    request = self.create!(parameters: {cfs_directory_id: cfs_directory.id, type: 'directory'}, email: user.email, status: 'pending')
    handler = Downloader::DirectoryHandler.new(request)
    request.send_export_request(handler.export_request_message(recursive: recursive))
  end

  def self.create_for_file_list(cfs_file_list, user)
    request = self.create!(email: user.email, status: 'pending', parameters: {type: 'file_list', cfs_file_ids: cfs_file_list.collect(&:id)})
    handler = Downloader::FileListHandler.new(request)
    request.send_export_request(handler.export_request_message(cfs_file_list))
  end

  def initialize_parameters
    self.parameters ||= Hash.new
  end

  def handle_request_received(handler, response)
    self.status = 'request_received'
    self.downloader_id = response['id']
    self.save!
  end

  def handle_error(handler, response)
    self.status = 'error'
    self.save!
    CfsMailer.export_error_user(handler.export_error_text, email, response).deliver_now
    CfsMailer.export_error_admin(handler.export_admin_error_text, response).deliver_now
  end

  def handle_request_completed(handler, response)
    self.status = 'request_completed'
    self.save!
    CfsMailer.export_complete(handler.export_complete_text, email, response).deliver_now
  end

  def send_export_request(message)
    AmqpHelper::Connector[:downloader].send_message(Settings.downloader.outgoing_queue, message)
  end

end
