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

  desc 'Reindex searchable models incrementally via delayed jobs'
  task incremental_reindex: :environment do
    Rails.application.eager_load!
    models = ApplicationRecord.subclasses.select {|c| c.respond_to?(:search) and c.respond_to?(:index)}
    models.each do |model|
      if Job::SunspotReindex.where(class_name: model.to_s).present?
        puts "Already have a reindex in progress for #{model}."
      else
        puts "Starting a reindex for #{model}."
        Job::SunspotReindex.create_for(model, start_id: 1, end_id: model.order('id desc').first.id,
                                       batch_size: 5000)
      end
    end
  end

  desc 'Show searchable models with incremental reindexes in progress'
  task show_incremental_reindexes: :environment do
    Job::SunspotReindex.all.sort_by(&:class_name).each do |job|
      puts "#{job.class_name}: start_id: #{job.start_id} end_id: #{job.end_id}"
    end
  end

end