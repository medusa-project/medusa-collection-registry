require 'rake'

namespace :sunspot do
  desc 'Optimize the current solr index'
  task optimize: :environment do
    #Set the timeout, passing through the session proxy to the real session and then to the
    #appropriate config option. Note that this may not have any effect if a connection (RSolr::Client) has
    #already been made, but in this case that should not happen until we call optimize
    Sunspot.session.session.config.solr.read_timeout = 3600
    Sunspot.optimize
  end
end