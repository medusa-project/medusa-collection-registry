require 'rake'

namespace :medusa do
  namespace :rails_cache do
    desc "Clear Rails cache (sessions, views, etc.)"
    task clear: :environment do
      Rails.cache.clear
    end
  end

  namespace :cfs_stats do
    desc "Refresh all cfs stats directly from the database"
    task refresh: :environment do
      CfsDirectory.update_all_tree_stats_from_db
    end
  end
end

