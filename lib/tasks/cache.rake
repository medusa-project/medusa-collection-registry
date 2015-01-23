require 'rake'

namespace :medusa do
  namespace :rails_cache do
    desc "Clear Rails cache (sessions, views, etc.)"
    task clear: :environment do
      Rails.cache.clear
    end
  end
end

