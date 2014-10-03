namespace :book_tracker do
  desc 'Scans the filesystem for MARCXML records to import, and imports them.'
  task import: :environment do
    fs = BookTracker::Filesystem.new
    fs.import
  end

  desc 'Checks to see whether each item exists in HathiTrust.'
  task check_hathitrust: :environment do
    ht = BookTracker::Hathitrust.new
    ht.check
  end

  desc 'Checks to see whether each item exists in Internet Archive.'
  task check_internet_archive: :environment do
    ia = BookTracker::InternetArchive.new
    ia.check
  end

end
