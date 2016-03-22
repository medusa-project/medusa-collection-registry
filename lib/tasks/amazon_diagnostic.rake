#TODO remove after problem has been solved
#Note that this isn't necessarily portable - I'm make assumptions about things like the amazon manifest
#locations instead of configuring

require 'rake'
require 'open3'

namespace :amazon_diagnostic do

  desc 'Find file groups that have incremental backups'
  task find_incremental_backups: :environment do
    BitLevelFileGroup.order(:id).each do |fg|
      if fg.amazon_backups.count > 1
        puts "#{fg.collection_id}:#{fg.id}:#{fg.amazon_backups.count}"
      end
    end
  end

end