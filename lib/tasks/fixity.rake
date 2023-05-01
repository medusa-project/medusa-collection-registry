require 'rake'
require 'fileutils'
require 'csv'

namespace :fixity do

  desc "Run fixity on a number of files. BATCH_SIZE sets number. Default is 10000."
  task run_batch: :environment do
    runner = Fixity::BatchRunner.new((ENV['BATCH_SIZE'] || 10000).to_i)
    runner.run
  end

  desc "Fetch and handle fixity responses"
  task handle_fixity_responses: :environment do
    MessageResponse::Fixity.handle_responses
  end

  desc "Email about any bad fixity reports"
  task report_problems: :environment do
    if CfsFile.not_found_fixity.count > 0 or CfsFile.bad_fixity.count > 0
      FixityErrorMailer.report_problems.deliver_now
    end
  end

  desc "Make CSV report about bad/missing fixity files"
  task csv_report: :environment do
    f = File.open('fixity_report.csv', 'wb')
    csv = CSV.new(f)
    csv << %w(cfs_file_id status cfs_directory_id file_group_id path)
    problem_files = CfsFile.not_found_fixity.to_a + CfsFile.bad_fixity.to_a
    problem_files.each do |f|
      csv << [f.id, f.fixity_check_status, f.cfs_directory_id, f.file_group.id, f.absolute_path]
    end
    f.close
  end
end


