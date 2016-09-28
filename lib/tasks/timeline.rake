require 'rake'

namespace :timeline do
  desc 'Compute and store timeline stats'
  task compute_stats: :environment do
    ActiveRecord::Base.connection.execute('SELECT create_timeline_stats();')
  end
end