require 'rake'
require 'fileutils'

def amqp_connector
  AmqpHelper::Connector[:medusa]
end

namespace :fits do

  DEFAULT_FITS_BATCH_SIZE = 1000
  FITS_STOP_FILE = File.join(Rails.root, 'fits_stop.txt')

  desc "Run fits on a number of currently unchecked files. [FITS_]BATCH_SIZE sets number (default #{DEFAULT_FITS_BATCH_SIZE})"
  task run_batch: :environment do
    batch_size = (ENV['FITS_BATCH_SIZE'] || ENV['BATCH_SIZE'] || DEFAULT_FITS_BATCH_SIZE).to_i
    errors = Hash.new
    bar = ProgressBar.new(batch_size)
    CfsFile.without_fits.where('size is not null').limit(batch_size).pluck(:id).in_groups_of(500) do |group|
      CfsFile.where(id: group).each do |cfs_file|
        break if File.exist?(FITS_STOP_FILE)
        begin
          cfs_file.ensure_fits_xml
        rescue RSolr::Error::Http => e
          FileUtils.touch(FITS_STOP_FILE)
          errors[cfs_file.id] = e
        rescue Exception => e
          if e.to_s.match('Code 500')
            begin
              Fits::Runner.update_cfs_file(cfs_file)
            rescue Exception => fits_runner_error
              errors[cfs_file.id] = fits_runner_error
            end
          else
            errors[cfs_file.id] = e
          end
        ensure
          bar.increment!
        end
      end
    end
    if errors.present?
      error_string = StringIO.new
      error_string << "Fits Errors"
      errors.each do |id, error|
        error_string.puts "#{id}: #{error}"
      end
      GenericErrorMailer.error(error_string.string, subject: 'FITS batch error').deliver_now
    end
    Sunspot.commit
  end

=begin
  desc "Run fits via AMQP on a number of currently unchecked files. [FITS_]BATCH_SIZE sets number (default #{DEFAULT_FITS_BATCH_SIZE})"
  task run_amqp_batch: :environment do
    request_fits_amqp if outgoing_message_count.zero? and incoming_message_count.zero?
    report_errors(handle_incoming_messages) if incoming_message_count > 0
  end
=end

=begin
  desc "Handle incoming fits amqp messages."
  task handle_incoming_amqp_messages: :environment do
    report_errors(handle_incoming_messages) if incoming_message_count > 0
  end
=end

=begin
  desc "Handle incoming fits messages."
  task handle_incoming_messages: :environment do
    report_errors(handle_incoming_messages) if incoming_message_count > 0
  end
=end


=begin
  MAX_SLEEPS = 12
  SLEEP_TIME = 10
  #return a hash of any errors
  def handle_incoming_messages
    errors = Hash.new
    sleeps = 0
    messages_handled = 0
    while sleeps < MAX_SLEEPS do
      break if File.exist?(FITS_STOP_FILE)
      amqp_connector.with_parsed_message(Settings.fits.incoming_queue) do |message|
        if message
          sleeps = 0
          messages_handled += 1
          cfs_file = CfsFile.find(message['pass_through']['cfs_file_id'])
          begin
            if message['status'] == 'success'
              cfs_file.update_fits_xml(xml: message['parameters']['fits_xml'])
            else
              cfs_file.ensure_fits_xml
            end
          rescue RSolr::Error::Http => e
            FileUtils.touch(FITS_STOP_FILE)
            errors[cfs_file.id] = e
          rescue Exception => e
            errors[cfs_file.id] = e
          end
          if (messages_handled % 100).zero?
            Sunspot.commit
            puts "Handled #{messages_handled} incoming messages"
          end
        else
          sleeps = sleeps + 1
          sleep SLEEP_TIME
        end
      end
    end
    puts "Slept for #{MAX_SLEEPS * SLEEP_TIME} seconds - breaking" if sleeps >= MAX_SLEEPS
    Sunspot.commit
    return errors
  end
=end

=begin
  def report_errors(errors)
    if errors.present?
      error_string = StringIO.new
      error_string << "Fits Errors\n\n"
      errors.each do |id, error|
        error_string.puts "#{id}: #{error}"
      end
      GenericErrorMailer.error(error_string.string, subject: 'FITS batch error').deliver_now
    end
  end
=end

=begin
  def incoming_message_count
    amqp_connector.with_queue(Settings.fits.incoming_queue) {|q| q.message_count}
  end
=end

=begin
  def outgoing_message_count
    amqp_connector.with_queue(Settings.fits.outgoing_queue) {|q| q.message_count}
  end
=end

  #returns number of requests sent
=begin
  def request_fits_amqp
    batch_size = (ENV['FITS_BATCH_SIZE'] || ENV['BATCH_SIZE'] || DEFAULT_FITS_BATCH_SIZE).to_i
    count = 0 #keep separately, since we might not get batch_size
    CfsFile.without_fits.where('size is not null').limit(batch_size).pluck(:id).in_groups_of(500) do |group|
      CfsFile.where(id: group).each do |cfs_file|
        amqp_connector.send_message(Settings.fits.outgoing_queue, fits_request(cfs_file))
        count += 1
      end
    end
    return count
  end
=end

=begin
  def fits_request(cfs_file)
    {action: 'fits',
     pass_through: {cfs_file_id: cfs_file.id},
     parameters: {path: cfs_file.relative_path}}
  end
=end

end

