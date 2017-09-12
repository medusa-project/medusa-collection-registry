require 'open3'

class AmqpAccrual::IngestJob < Job::Base
  include AmqpConnector
  use_amqp_connector :medusa

  def self.create_for(client, message)
    job = self.new(staging_path: message['staging_path'], client: client)
    if find_by(staging_path: job.staging_path, client: client) or File.exist?(job.absolute_target_file) or job.staging_path.blank?
      Rails.logger.error "Failed to create Amqp Accrual Job for client: #{client} message: #{message}. Duplicate file or blank path."
      send_duplicate_file_message(client, message)
    else
      job.save!
      Delayed::Job.enqueue(job, queue: AmqpAccrual::Config.delayed_job_queue(client), priority: 50)
    end
  rescue Exception => e
    Rails.logger.error "Failed to create Amqp Accrual Job for client: #{client} message: #{message}. Error: #{e}"
    send_unknown_error_message(client, message, e)
  end

  def perform
    ensure_uuid
    ensure_directories
    rsync_file
    create_cfs_file
    do_assessment
    send_return_message
  rescue Exception => e
    Rails.logger.error("Error ingesting Amqp Accrual file. Job: #{self.id}\nError: #{e}")
    raise
  end

  def absolute_target_file
    File.join(AmqpAccrual::Config.cfs_directory(self.client).absolute_path, target_file)
  end

  protected

  def ensure_uuid
    self.uuid ||= MedusaUuid.generate
    self.save!
  end

  def item_path_from_root
    File.dirname(staging_path.split('/').drop(1).join('/'))
  end

  def target_directory
    item_path_from_root
  end

  def target_file
    File.join(target_directory, file_name)
  end

  def file_name
    File.basename(staging_path)
  end

  def source_file
    File.join(AmqpAccrual::Config.staging_directory(client), staging_path)
  end

  def ensure_directories
    FileUtils.mkdir_p(File.join(AmqpAccrual::Config.cfs_directory(client).absolute_path, target_directory))
    AmqpAccrual::Config.cfs_directory(client).ensure_directory_at_relative_path(target_directory)
  end

  def rsync_file
    opts = %w(-a --no-l -L --ignore-times --chmod Dug+w --safe-links)
    out, err, status = Open3.capture3('rsync', *opts, source_file, absolute_target_file)
    unless status.success?
      message = <<MESSAGE
Error doing rsync for Amqp Accrual job #{self.id}.
STDOUT: #{out}
STDERR: #{err}
Rescheduling.
MESSAGE
      Rails.logger.error message
      raise RuntimeError, message
    end
  end

  def create_cfs_file
    transaction do
      file = immediate_parent_directory.cfs_files.find_or_create_by!(name: file_name)
      file.create_amqp_accrual_event
      file.uuid = uuid
    end
  end

  def immediate_parent_directory
    AmqpAccrual::Config.cfs_directory(client).find_directory_at_relative_path(target_directory)
  end

  def do_assessment
    immediate_parent_directory.cfs_files.find_by(name: file_name).try(:run_initial_assessment)
    Sunspot.commit
  end

  def send_return_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), return_message)
  end

  def return_message
    {operation: 'ingest', staging_path: staging_path,
     medusa_path: target_file, status: 'ok', uuid: uuid}.clone.tap do |message|
      message.merge!(return_directory_information) if AmqpAccrual::Config.return_directory_information?(client)
    end
  end

  def return_directory_information
    parent_directory = immediate_parent_directory
    grandparent_directory = parent_directory.parent
    item_root_directory = parent_directory.ancestors_and_self.drop(1).first
    Hash.new.tap do |h|
      h[:parent_dir] = dir_to_json(parent_directory)
      h[:grandparent_dir] = dir_to_json(grandparent_directory)
      h[:item_root_dir] = dir_to_json(item_root_directory)
    end
  end

  def dir_to_json(cfs_directory)
    Hash.new.tap do |h|
      h[:id] = cfs_directory.id
      h[:uuid] = cfs_directory.uuid
      h[:relative_path] = cfs_directory.relative_path_from_root
      h[:url_path] = Rails.application.routes.url_helpers.cfs_directory_path(cfs_directory)
    end
  end

  def self.duplicate_file_message(incoming_message)
    {operation: 'ingest', staging_path: incoming_message['staging_path'],
     status: 'error', error: 'File with the path already exists or is already scheduled for ingestion'}
  end

  def self.unknown_error_message(incoming_message, error)
    {operation: 'ingest', staging_path: incoming_message['staging_path'],
     status: 'error', error: "Unknown error: #{error}"}
  end

  def self.send_duplicate_file_message(client, incoming_message)
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), duplicate_file_message(incoming_message))
  end

  def self.send_unknown_error_message(client, incoming_message, error)
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), unknown_error_message(incoming_message, error))
  end

end
