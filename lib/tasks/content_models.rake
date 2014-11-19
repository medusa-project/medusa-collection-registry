require 'rake'
require 'nokogiri'

namespace :content_models do
  desc 'Ingest medusa content models, overwriting old versions if necessary'
  task refresh: [:remove, :ingest_new] do
    #nothing - just the two other tasks
  end

  desc 'Ingest medusa content models not currently present in the repository'
  task ingest_new: :environment do
    ActiveFedora.init
    each_content_model_file_and_pid do |file, pid|
      begin
        repository = ActiveFedora::Base.connection_for_pid(pid)
        Rubydora::DigitalObject.find(pid, repository)
        puts "Already present: #{pid}"
      rescue Rubydora::RecordNotFound
        #this is actually the case where we'll try to ingest - I didn't see a nicer way to do it in Rubydora
        begin
          repository.ingest(file: File.read(file), pid: pid)
          puts "Ingested: #{pid}"
        rescue Exception => e
          puts "Error ingesting #{pid}: #{e.to_s}"
        end
      end
    end
  end

  desc 'Remove medusa content models that are currently in the repository'
  task remove: :environment do
    each_content_model_file_and_pid do |file, pid|
      begin
        repository = ActiveFedora::Base.connection_for_pid(pid)
        Rubydora::DigitalObject.find(pid, repository).delete
        puts "Deleted: #{pid}"
      rescue Rubydora::RecordNotFound
        #do nothing if the object is simply not found
      rescue Exception => e
        puts "Error deleting #{pid}: #{e.to_s}"
      end
    end
  end

  #for each content model in submodules/medusa-content-models yield the file path and the pid to a block
  def each_content_model_file_and_pid
    Dir[File.join(Rails.root, 'submodules', 'medusa-content-models', '*.xml')].sort.each do |path|
      doc = Nokogiri::XML::Document.parse(File.read(path))
      pid = doc.at_xpath('foxml:digitalObject')['PID']
      yield path, pid
    end
  end

end
