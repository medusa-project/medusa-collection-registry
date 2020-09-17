class AmqpAccrual::IngestJob < Job::Base
  include AmqpConnector
  use_amqp_connector :medusa
  serialize :incoming_message

  def self.create_for(client, message)
    job = self.new(incoming_message: message, client: client)
    job.target_key = job.relative_target_key
    if job.content_exists? or job.staging_key.blank?
      Rails.logger.error "Failed to create Amqp Accrual Job for client: #{client} message: #{message}. Duplicate file or blank path."
      send_duplicate_file_message(client, message)
    else
      begin
        job.save!
        job.enqueue_job
      rescue => e
        Rails.logger.error "Failed to create Amqp Accrual Job for client: #{client} message: #{message}. Probably a duplicate request. Original error: #{e}"
        send_duplicate_file_message(client, message)
      end
    end
  rescue Exception => e
    Rails.logger.error "Failed to create Amqp Accrual Job for client: #{client} message: #{message}. Error: #{e}"
    logger.error e.backtrace.join("\n")
    send_unknown_error_message(client, message, e)
  end

  def queue
    AmqpAccrual::Config.delayed_job_queue(self.client)
  end

  def priority
    Settings.delayed_job.priority.amqp_accrual_ingest_job
  end

  def perform
    unless self.copied
      ensure_uuid
      ensure_cfs_directory_parents
      copy_content
    end
    create_cfs_file
    do_assessment
    send_return_message
  rescue Exception => e
    Rails.logger.error("Error ingesting Amqp Accrual file. Job info:\n\n"\
        "#{YAML::dump(self)}\n\n"\
        "Error: #{e}\n#{e.backtrace}")
    raise e
  end

  def content_exists?
    target_root.exist?(full_target_key)
  end

  def staging_key
    incoming_message['staging_key'] || incoming_message['staging_path']
  end

  def relative_target_key
    incoming_message['target_key'] || File.join(staging_key.split('/').drop(1))
  end

  protected

  def self.pass_through(incoming_message)
    incoming_message['pass_through'] rescue "Unable to read pass_through"
  end

  def pass_through
    incoming_message['pass_through'] rescue "Unable to read pass_through"
  end

  def ensure_uuid
    self.uuid ||= MedusaUuid.generate
    self.save!
  end

  def target_file_basename
    File.basename(relative_target_key)
  end

  def target_root
    Application.storage_manager.main_root
  end

  def cfs_directory
    AmqpAccrual::Config.cfs_directory(client)
  end

  def relative_target_dirname
    File.dirname(relative_target_key)
  end

  def full_target_key
    File.join(cfs_directory.relative_path, relative_target_key)
  end

  def source_root
    Application.storage_manager.amqp_root_at(self.client)
  end

  def ensure_cfs_directory_parents
    cfs_directory.ensure_directory_at_relative_path(relative_target_dirname)
  end

  #TODO - we maybe could still make this better. This should catch some failures that
  # we currently get, though.
  def copy_content
    raise "Object does not exist at source key" unless source_root.exist?(staging_key)
    if target_root.exist?(full_target_key)
      if target_root.md5_sum(full_target_key) == source_root.md5_sum(staging_key)
        return
      else
        raise "Object already exists at target key with different md5 sum"
      end
    end
    target_root.copy_content_to(full_target_key, source_root, staging_key)
    update_attribute(:copied, true)
  end

  def create_cfs_file
    transaction do
      file = target_parent_cfs_directory.cfs_files.find_or_create_by!(name: target_file_basename)
      file.create_amqp_accrual_event
      file.uuid = uuid
    end
  end

  def target_parent_cfs_directory
    cfs_directory.find_directory_at_relative_path(relative_target_dirname)
  end

  def do_assessment
    target_parent_cfs_directory.cfs_files.find_by(name: target_file_basename).try(:run_initial_assessment)
    Sunspot.commit
  end

  def send_return_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), return_message)
  end

  def return_message
    {operation: 'ingest', staging_path: incoming_message['staging_path'], staging_key: incoming_message['staging_key'],
     pass_through: pass_through,
     medusa_path: relative_target_key, medusa_key: relative_target_key, status: 'ok', uuid: uuid}.clone.tap do |message|
      message.merge!(return_directory_information) if AmqpAccrual::Config.return_directory_information?(client)
    end
  end

  def return_directory_information
    parent_directory = target_parent_cfs_directory
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
    {operation: 'ingest', staging_path: incoming_message['staging_path'], staging_key: incoming_message['staging_key'],
     pass_through: pass_through(incoming_message),
     status: 'error', error: 'File with the path already exists, is already scheduled for ingestion, or stating key was blank'}
  end

  def self.unknown_error_message(incoming_message, error)
    {operation: 'ingest', staging_path: incoming_message['staging_path'], staging_key: incoming_message['staging_key'],
     pass_through: pass_through(incoming_message), status: 'error', error: "Unknown error: #{error}"}
  end

  def self.send_duplicate_file_message(client, incoming_message)
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), duplicate_file_message(incoming_message))
  end

  def self.send_unknown_error_message(client, incoming_message, error)
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), unknown_error_message(incoming_message, error))
  end

end
