require 'rake'

namespace :medusa do
  namespace :cache do
    desc "Update bit level file group size and count"
    task :update_bit_level_metrics => :environment do
      #TODO: Shouldn't be needed anymore - remove after deploying code and calling cron job is removed. For now, noop
    end
  end
end

