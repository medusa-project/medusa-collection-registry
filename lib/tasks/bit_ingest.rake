require 'rake'

namespace :bit_level do

  desc 'Ingest to collection id INGEST_COLLECTION from directory INGEST_DIR on server'
  task :ingest => :environment do
    collection = Collection.find ENV['INGEST_COLLECTION']
    dir = ENV['INGEST_DIR']
    collection.bit_ingest(dir)
  end

  desc 'Export from collection id EXPORT_COLLECTION to directory EXPORT_DIR on server'
  task :export => :environment do
    collection = Collection.find ENV['EXPORT_COLLECTION']
    dir = ENV['EXPORT_DIR']
    collection.bit_export(dir)
  end
  
end