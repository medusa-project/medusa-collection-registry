require 'rake'
require 'fileutils'
namespace :fixity do

  DEFAULT_BATCH_SIZE = 100000
  FIXITY_STOP_FILE = File.join(Rails.root, 'fixity_stop.txt')
  desc "Run fixity on a number of files. BATCH_SIZE sets number (default #{DEFAULT_BATCH_SIZE})"
  task run_batch: :environment do
    batch_size = (ENV['BATCH_SIZE'] || DEFAULT_BATCH_SIZE).to_i
    errors = Hash.new
    bar = ProgressBar.new(batch_size)
    fixity_files(batch_size).each.with_index do |cfs_file, i|
      break if File.exist?(FIXITY_STOP_FILE)
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
        FileUtils.touch(FIXITY_STOP_FILE)
      rescue Exception => e
        errors[cfs_file] = e.to_s
      end
      Sunspot.commit if (i % 100).zero?
    end
    if errors.present?
      error_string = StringIO.new
      error_string.puts "Fixity errors"
      errors.each do |k, v|
        error_string.puts "#{k.id}: #{v}"
      end
      GenericErrorMailer.error(error_string.string, subject: 'Fixity batch error').deliver_now
    end
    Sunspot.commit
  end

  desc "Email about any bad fixity reports"
  task report_problems: :environment do
    if CfsFile.not_found_fixity.count > 0 or CfsFile.bad_fixity.count > 0
      FixityErrorMailer.report_problems.deliver_now
    end
  end
end

# def fixity_files(batch_size)
#   if CfsFile.where(fixity_check_status: nil).first
#     CfsFile.where(fixity_check_status: nil).limit(batch_size)
#   else
#     timeout = (Settings.medusa.fixity_interval || 90).days
#     CfsFile.where('fixity_check_time < ?', Time.now - timeout).order('fixity_check_time asc').limit(batch_size)
#   end
# end

def fixity_files(batch_size)
  if CfsFile.where(fixity_check_status: nil).first
    CfsFile.where(fixity_check_status: nil).limit(batch_size)
  else
    #timeout = (Settings.medusa.fixity_interval || 90).days
    CfsFile.where('fixity_check_time < ?', Date.parse('2017-06-04')).order('fixity_check_time asc').limit(batch_size)
    #CfsFile.where('fixity_check_time < ?', Time.now - timeout).order('fixity_check_time asc').limit(batch_size)
  end
end
