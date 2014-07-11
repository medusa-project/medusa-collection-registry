require 'rake'

namespace :medusa do
  namespace :cache do
    desc "Update bit level file group size and count"
    task :update_bit_level_metrics => :environment do
      BitLevelFileGroup.all.each do |file_group|
        file_group.file_count
        file_group.file_size
      end
    end
  end
end

