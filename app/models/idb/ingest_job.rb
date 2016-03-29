require 'open3'

class Idb::IngestJob < Job::Base

  def self.create_for(message)
    job = self.create!(staging_path: message['staging_path'])
    Delayed::Job.enqueue(job)
  end

  def perform
    ensure_uuid
    ensure_directories
    rsync_file
    create_cfs_file
    schedule_assessments
    send_return_message
  rescue Exception => e
    Rails.logger.error("Error ingesting IDB file. Job: #{self.id}\nError: #{e}")
    raise
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

  def absolute_target_file
    File.join(Idb::Config.instance.idb_cfs_directory.absolute_path, target_file)
  end

  def file_name
    File.basename(staging_path)
  end

  def source_file
    File.join(Idb::Config.instance.staging_directory, staging_path)
  end

  def ensure_directories
    FileUtils.mkdir_p(File.join(Idb::Config.instance.idb_cfs_directory.absolute_path, target_directory))
    Idb::Config.instance.idb_cfs_directory.ensure_directory_at_relative_path(target_directory)
  end

  def rsync_file
    opts = %w(-a --ignore-times --chmod Dug+w)
    out, err, status = Open3.capture3('rsync', *opts, source_file, absolute_target_file)
    unless status.success?
      message = <<MESSAGE
Error doing rsync for idb ingest job #{self.id}.
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
      file = immediate_parent_directory.cfs_files.create!(name: file_name)
      file.uuid = uuid
    end
  end

  def immediate_parent_directory
    Idb::Config.instance.idb_cfs_directory.find_directory_at_relative_path(target_directory)
  end

  def schedule_assessments
    immediate_parent_directory.make_and_assess_tree
  end

  def send_return_message
    AmqpConnector.connector(:medusa).send_message(Idb::Config.instance.outgoing_queue, return_message)
  end

  def return_message
    {operation: 'ingest', staging_path: staging_path,
     medusa_path: target_file,
     status: 'ok', uuid: uuid}
  end

end