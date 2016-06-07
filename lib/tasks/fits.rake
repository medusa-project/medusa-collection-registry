require 'rake'

namespace :fits do

  DEFAULT_FITS_BATCH_SIZE = 1000
  desc "Run fits on a number of currently unchecked files. FITS_BATCH_SIZE sets number (default #{DEFAULT_FITS_BATCH_SIZE})"
  task run_batch: :environment do
    batch_size = ENV['FITS_BATCH_SIZE'] || DEFAULT_FITS_BATCH_SIZE
    CfsFile.where(fits_serialized: false).order('size desc').where('size is not null').limit(batch_size).each do |cfs_file|
      begin
        cfs_file.ensure_fits_xml
      rescue Exception => e
        puts "#{cfs_file.id}: #{e}"
      end
    end
  end

end