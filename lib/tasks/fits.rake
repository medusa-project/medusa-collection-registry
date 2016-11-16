require 'rake'
require 'fileutils'

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

  desc "Run fits via AMQP on a number of currently unchecked files. [FITS_]BATCH_SIZE sets number (default #{DEFAULT_FITS_BATCH_SIZE})"
  task run_amqp_batch: :environment do
    request_fits_amqp if outgoing_message_count.zero? and incoming_message_count.zero?
    report_errors(handle_incoming_messages) if incoming_message_count > 0
  end

  desc "Handle incoming fits amqp messages."
  task handle_incoming_amqp_messages: :environment do
    report_errors(handle_incoming_messages) if incoming_message_count > 0
  end

  #TODO: We just need this temporarily, until we've fixed all this stuff up
  desc "Fix up long fits files"
  task fix_long: :environment do
    require 'pstore'
    store_file = File.join(ENV['HOME'], 'tmp', 'long_fits.pstore')
    unless File.exist?(store_file)
      puts "Store file not found. Exiting"
      return
    end
    store = PStore.new(store_file)
    store.ultra_safe = true
    continue = true
    Signal.trap('INT') do
      puts "preparing to shutdown"
      continue = false
    end
    bar = nil
    store.transaction do
      bar = ProgressBar.new(store[:ids].length)
    end
    while continue
      store.transaction do
        if store[:ids].length.zero?
          puts "No more ids to do"
          continue = false
        end
        id = store[:ids].pop
        if cfs_file = CfsFile.find_by(id: id)
          xml = cfs_file.fits_xml
          doc = Nokogiri::XML(xml)
          doc.css('fits toolOutput').remove
          cfs_file.fits_result.xml = doc.to_xml
        end
        bar.increment!
      end
    end
  end

  desc "fits files still to be fixed"
  task fix_long_count: :environment do
    require 'pstore'
    store_file = File.join(ENV['HOME'], 'tmp', 'long_fits.pstore')
    unless File.exist?(store_file)
      puts "Store file not found. Exiting"
      return
    end
    store = PStore.new(store_file)
    store.ultra_safe = true
    count = store.transaction { store[:ids].count }
    puts "#{count} long fits files remaining"
  end

  MAX_SLEEPS = 12
  SLEEP_TIME = 10
  #return a hash of any errors
  def handle_incoming_messages
    bar ||= ProgressBar.new([incoming_message_count, 1].max)
    errors = Hash.new
    sleeps = 0
    messages_handled = 0
    while incoming_message_count > 0 and sleeps < MAX_SLEEPS do
      break if File.exist?(FITS_STOP_FILE)
      AmqpConnector.connector(:medusa).with_parsed_message(Settings.fits.incoming_queue) do |message|
        if message
          sleeps = 0
          messages_handled += 1
          cfs_file = CfsFile.find(message['pass_through']['cfs_file_id'])
          begin
            if message['status'] == 'success'
              cfs_file.update_fits_xml(xml: message['parameters']['fits_xml'])
            else
              Fits::Runner.update_cfs_file(cfs_file)
            end
          rescue RSolr::Error::Http => e
            FileUtils.touch(FITS_STOP_FILE)
            errors[cfs_file.id] = e
          rescue Exception => e
            errors[cfs_file.id] = e
          end
          Sunspot.commit if (messages_handled % 100).zero?
          bar.increment!
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

  def report_errors(errors)
    if errors.present?
      error_string = StringIO.new
      error_string << "Fits Errors\n\n"
      errors.each do |id, error|
        error_string.puts "#{id}: #{error}"
      end
      GenericErrorMailer.error(error_string.string, subject: 'FITS AMQP batch error').deliver_now
    end
  end

  def incoming_message_count
    AmqpConnector.connector(:medusa).with_queue(Settings.fits.incoming_queue) { |q| q.message_count }
  end

  def outgoing_message_count
    AmqpConnector.connector(:medusa).with_queue(Settings.fits.outgoing_queue) { |q| q.message_count }
  end

  #returns number of requests sent
  def request_fits_amqp
    batch_size = (ENV['FITS_BATCH_SIZE'] || ENV['BATCH_SIZE'] || DEFAULT_FITS_BATCH_SIZE).to_i
    count = 0 #keep separately, since we might not get batch_size
    CfsFile.without_fits.where('size is not null').limit(batch_size).pluck(:id).in_groups_of(500) do |group|
      CfsFile.where(id: group).each do |cfs_file|
        AmqpConnector.connector(:medusa).send_message(Settings.fits.outgoing_queue, fits_request(cfs_file))
        count += 1
      end
    end
    return count
  end

  def fits_request(cfs_file)
    {action: 'fits',
     pass_through: {cfs_file_id: cfs_file.id},
     parameters: {path: cfs_file.relative_path}}
  end

end

