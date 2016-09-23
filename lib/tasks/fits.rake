require 'rake'
require 'fileutils'

namespace :fits do

  DEFAULT_FITS_BATCH_SIZE = 1000
  STOP_FILE = File.join(Rails.root, 'fits_stop.txt')
  desc "Run fits on a number of currently unchecked files. FITS_BATCH_SIZE sets number (default #{DEFAULT_FITS_BATCH_SIZE})"
  task run_batch: :environment do
    batch_size = (ENV['FITS_BATCH_SIZE'] || ENV['BATCH_SIZE'] || DEFAULT_FITS_BATCH_SIZE).to_i
    errors = Hash.new
    bar = ProgressBar.new(batch_size)
    CfsFile.without_fits.id_order.where('size is not null').limit(batch_size).each do |cfs_file|
      break if File.exist?(STOP_FILE)
      begin
        cfs_file.ensure_fits_xml
      rescue RSolr::Error::Http => e
        FileUtils.touch(STOP_FILE)
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
    if errors.present?
      error_string = StringIO.new
      error_string << "Fits Errors"
      errors.each do |id, error|
        error_string.puts "#{id}: #{error}"
      end
      GenericErrorMailer.error(error_string.string).deliver_now
    end
    Sunspot.commit
  end
end

