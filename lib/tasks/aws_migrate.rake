require 'rake'

namespace :aws_migrate do

  desc 'Dump CSV of collection id, file group id, db file count'
  task counts: :environment do
    CSV.open('uploads.csv') do |csv|
      BitLevelFileGroup.each do |fg|
        csv << [fg.collection.id, fg.id, fg.total_files]
      end
    end
  end

end