require 'rake'
require 'open3'

namespace :bit_level do

  desc 'Ingest to FileGroup id INGEST_FILE_GROUP from directory INGEST_DIR on server'
  task :file_group_ingest => :environment do
    file_group_id = ENV['INGEST_FILE_GROUP']
    ingest_dir = ENV['INGEST_DIR']
    unless (file_group_id.present? and ingest_dir.present?)
      puts "Must specify INGEST_FILE_GROUP and INGEST_DIR"
      exit 0
    end
    file_group = FileGroup.find(file_group_id)
    reporting_thread = Thread.new do
      ingest_report(file_group, ingest_dir)
    end
    file_group.bit_ingest(ingest_dir)
    puts "Reporting status: #{reporting_thread.status} #{reporting_thread.status.class}"
  end

  desc 'Export from FileGroup id EXPORT_FILE_GROUP to directory EXPORT_DIR on server'
  task :file_group_export => :environment do
    unless (ENV['EXPORT_FILE_GROUP'].present? and ENV['EXPORT_DIR'].present?)
      puts "Must specify EXPORT_FILE_GROUP and EXPORT_DIR"
      exit 0
    end
    file_group = FileGroup.find ENV['EXPORT_FILE_GROUP']
    file_group.bit_export(ENV['EXPORT_DIR'])
  end


  desc 'Export from collection id EXPORT_COLLECTION to directory EXPORT_DIR on server'
  task :collection_export => :environment do
    unless (ENV['EXPORT_COLLECTION'].present? and ENV['EXPORT_DIR'].present?)
      puts "Must specify EXPORT_COLLECTION and EXPORT_DIR"
      exit 0
    end
    collection = Collection.find ENV['EXPORT_COLLECTION']
    collection.bit_export(ENV['EXPORT_DIR'])
  end

  def ingest_report(file_group, ingest_dir)
    include ActionView::Helpers::NumberHelper
    file_count_thread = Thread.new do
      file_count_thread[:count] = count_files(ingest_dir)
    end
    start_time = Time.now
    loop do
      sleep 60
      #it may take a moment for the root directory to exist
      root_dir = nil
      if root_dir ||= file_group.root_directory(true)
        file_count ||= file_count_thread[:count]
        ingested_file_count = root_dir.recursive_ingested_file_count
        ingested_size = number_to_human_size(root_dir.recursive_ingested_file_size)
        elapsed_time = ((Time.now - start_time) / 3600.0).round(2)
        puts "Ingested Files: #{ingested_file_count} Total Files: #{file_count || '???'} Time: #{elapsed_time} h Ingested Size: #{ingested_size}"
      end
    end
  rescue Exception => e
    puts "Ingest exception: #{e}"
    raise e
  end

  def count_files(dir)
    output, status = Open3.capture2("tree #{dir} | tail -n 1")
    output.match(/(\d+)\s+files/)
    $1
  end

end