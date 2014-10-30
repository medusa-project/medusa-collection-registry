namespace :book_tracker do
  desc 'Scans the filesystem for MARCXML records to import, and imports them.'
  task import: :environment do
    BookTracker::Filesystem.new.import
  end

  desc 'Checks to see whether each item exists in Google.'
  task check_google: :environment do
    BookTracker::Google.new.check
  end

  desc 'Checks to see whether each item exists in HathiTrust.'
  task check_hathitrust: :environment do
    BookTracker::Hathitrust.new.check
  end

  desc 'Checks to see whether each item exists in Internet Archive.'
  task check_internet_archive: :environment do
    BookTracker::InternetArchive.new.check
  end

end
