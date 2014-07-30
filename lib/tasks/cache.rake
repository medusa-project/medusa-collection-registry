require 'rake'

namespace :medusa do
  namespace :cache do
    desc "Update bit level file group size and count"
    task :update_bit_level_metrics => :environment do
      BitLevelFileGroup.update_cached_file_stats
    end
  end
end

