require 'rake'

namespace :fixity do

  DEFAULT_BATCH_SIZE = 1000
  desc "Run fixity on a number of files. BATCH_SIZE sets number (default #{DEFAULT_BATCH_SIZE})"
  task run_batch: :environment do
    batch_size = (ENV['BATCH_SIZE'] || DEFAULT_BATCH_SIZE).to_i
    errors = Hash.new
    bar = ProgressBar.new(batch_size)
    files = CfsFile.where(fixity_check_status: nil).limit(batch_size)
    files.each do |cfs_file|
      begin
        cfs_file.update_fixity_status_with_event
        puts "#{cfs_file.id}: #{cfs_file.fixity_check_status}"
        unless cfs_file.fixity_check_status == 'ok'
          case cfs_file_fixity_check_status
            when 'bad'
              errors[cfs_file] = 'Bad fixity'
            when 'nf'
              errors[cfs_file] = 'Not found'
            else
              raise RuntimeError, 'Unrecognized fixity check status'
          end
        end
        bar.increment!
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
      puts error_string
      GenericErrorMailer.error(error_string.string).deliver_now
    end
  end
end

