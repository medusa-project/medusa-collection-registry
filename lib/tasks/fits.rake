require 'rake'

namespace :fits do

  DEFAULT_FITS_BATCH_SIZE = 1000
  desc "Run fits on a number of currently unchecked files. FITS_BATCH_SIZE sets number (default #{DEFAULT_FITS_BATCH_SIZE})"
  task run_batch: :environment do
    batch_size = (ENV['FITS_BATCH_SIZE'] || DEFAULT_FITS_BATCH_SIZE).to_i
    errors = Hash.new
    bar = ProgressBar.new(batch_size)
    CfsFile.without_fits.where('size is not null').limit(batch_size).each do |cfs_file|
      begin
        cfs_file.ensure_fits_xml
      rescue Exception => e
        if e.to_s.match('Code 500')
          begin
           Fits::Runner.update_cfs_file(cfs_file)
          rescue Exception => fits_runner_error
            error[cfs_file.id] = fits_runner_error
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
  end
end

