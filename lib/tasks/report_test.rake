require 'rake'

namespace :report_test do
  task manifest: :environment do
    d = CfsDirectory.order(:id).first
    r = Report::CfsDirectoryManifest.new(d)
    File.open('report.tsv', 'w') do |f|
      r.generate_tsv(f)
    end
  end

  task map: :environment do
    d = CfsDirectory.order(:id).first
    r = Report::CfsDirectoryMap.new(d)
    File.open('report.txt', 'w') do |f|
      r.generate(f)
    end
  end

end