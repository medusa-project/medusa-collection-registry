#Use to collect general methods that more specific ingestors may want to use
#Also has concept of package_path to hold the root of the ingest package
#Subclasses should typically define the ingest method, which will ingest the package
#based at package_path
require 'active_fedora'

module Medusa
  class GenericIngestor

    attr_accessor :package_root

    def initialize(package_root)
      self.package_root = package_root
      ActiveFedora.init
    end

    #If there is an object with the given pid delete it and yield to the block.
    #For making this repeatable without hassle.
    def replacing_object(pid, klass = ActiveFedora::Base)
      begin
        object = klass.load_instance(pid)
        object.delete unless object.nil?
      rescue ActiveFedora::ObjectNotFoundError
        #nothing
      end
      yield
    end

    #return a Nokogiri::XML::Document on the file contents
    def file_to_xml(file)
      Nokogiri::XML::Document.parse(File.read(file))
    end

    def ingest
      raise NotImplementedError, "Subclass responsibility"
    end

  end
end