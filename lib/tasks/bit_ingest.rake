require 'rake'

namespace :bit_level do

  desc 'Ingest to FileGroup id INGEST_FILE_GROUP from directory INGEST_DIR on server'
  task :file_group_ingest => :environment do
    unless (ENV['INGEST_FILE_GROUP'].present? and ENV['INGEST_DIR'].present?)
      puts "Must specify INGEST_FILE_GROUP and INGEST_DIR"
      exit 0
    end
    file_group = FileGroup.find ENV['INGEST_FILE_GROUP']
    dir = ENV['INGEST_DIR']
    file_group.bit_ingest(dir)
  end

  desc 'Export from FileGroup id EXPORT_FILE_GROUP to directory EXPORT_DIR on server'
  task :file_group_export => :environment do
    unless (ENV['EXPORT_FILE_GROUP'].present? and ENV['EXPORT_DIR'].present?)
      puts "Must specify EXPORT_FILE_GROUP and EXPORT_DIR"
      exit 0
    end
    file_group = FileGroup.find ENV['EXPORT_FILE_GROUP']
    dir = ENV['EXPORT_DIR']
    file_group.bit_export(dir)
  end


  desc 'Export from collection id EXPORT_COLLECTION to directory EXPORT_DIR on server'
  task :collection_export => :environment do
    unless (ENV['EXPORT_COLLECTION'].present? and ENV['EXPORT_DIR'].present?)
      puts "Must specify EXPORT_COLLECTION and EXPORT_DIR"
      exit 0
    end
    collection = Collection.find ENV['EXPORT_COLLECTION']
    dir = ENV['EXPORT_DIR']
    collection.bit_export(dir)
  end

end