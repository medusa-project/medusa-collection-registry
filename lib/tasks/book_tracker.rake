namespace :book_tracker do
  desc 'Scans the filesystem for MARCXML records to import, and imports them.'
  task import: :environment do
    puts 'Importing items in the background.'
    Delayed::Job.enqueue(BookTracker::ImportJob.new)
  end

  desc 'Checks to see whether each item exists in Google.'
  task check_google: :environment do
    puts 'Checking Google in the background.'
    Delayed::Job.enqueue(BookTracker::GoogleJob.new)
  end

  desc 'Checks to see whether each item exists in HathiTrust.'
  task check_hathitrust: :environment do
    puts 'Checking HathiTrust in the background.'
    Delayed::Job.enqueue(BookTracker::HathitrustJob.new)
  end

  desc 'Checks to see whether each item exists in Internet Archive.'
  task check_internet_archive: :environment do
    puts 'Checking Internet Archive in the background.'
    Delayed::Job.enqueue(BookTracker::InternetArchiveJob.new)
  end

end
