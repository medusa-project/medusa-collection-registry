require 'rake'
require 'fileutils'
namespace :fixity do

  DEFAULT_BATCH_SIZE = 10000
  STOP_FILE = File.join(Rails.root, 'fixity_stop.txt')
  desc "Run fixity on a number of files. BATCH_SIZE sets number (default #{DEFAULT_BATCH_SIZE})"
  task run_batch: :environment do
    batch_size = (ENV['BATCH_SIZE'] || DEFAULT_BATCH_SIZE).to_i
    errors = Hash.new
    bar = ProgressBar.new(batch_size)
    fixity_files(batch_size).each do |cfs_file|
      break if File.exist?(STOP_FILE)
      begin
        cfs_file.update_fixity_status_with_event
        unless cfs_file.fixity_check_status == 'ok'
          puts "#{cfs_file.id}: #{cfs_file.fixity_check_status}"
          case cfs_file.fixity_check_status
            when 'bad'
              errors[cfs_file] = 'Bad fixity'
            when 'nf'
              errors[cfs_file] = 'Not found'
            else
              raise RuntimeError, 'Unrecognized fixity check status'
          end
        end
        bar.increment!
      rescue RSolr::Error::Http => e
        errors[cfs_file] = e.to_s
        FileUtils.touch(STOP_FILE)
      rescue Exception => e
        errors[cfs_file] = e.to_s
      end
    end
    if errors.present?
      error_string = StringIO.new
      error_string.puts "Fixity errors"
      errors.each do |k, v|
        error_string.puts "#{k.id}: #{v}"
      end
      GenericErrorMailer.error(error_string.string).deliver_now
    end
  end
end

def fixity_files(batch_size)
  if CfsFile.where(fixity_check_status: nil).first
    CfsFile.where(fixity_check_status: nil).limit(batch_size)
  else
    timeout = (Settings.medusa.fixity_interval || 90).days
    CfsFile.where('fixity_check_time < ?', Time.now - timeout).order('fixity_check_time asc').limit(batch_size)
  end
end
