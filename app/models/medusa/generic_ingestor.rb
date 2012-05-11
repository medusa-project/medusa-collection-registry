#Use to collect general methods that more specific ingestors may want to use
#Also has concept of package_path to hold the root of the ingest package
#Subclasses should typically define the ingest method, which will ingest the package
#based at package_path
module Medusa
  class GenericIngestor

    attr_accessor :package_root

    def initialize(package_root)
      self.package_root = package_root
      ActiveFedora.init
    end

    #If there is an object with the given pid delete it
    #Create a new object with the given class and yield to the block
    #return the new object
    def with_fresh_object(pid, klass = Medusa::GenericObject)
      delete_if_exists(pid, klass)
      klass.new(:pid => pid).tap do |object|
        yield object
      end
    end

    #Return the fedora object with the given pid and class
    #If it already exists simply return it
    #If not, then create it, yield it to the block, then return it
    def do_if_new_object(pid, klass = Medusa::GenericObject)
      begin
        object = klass.find(pid)
        return object if object and !object.new_object?
      rescue ActiveFedora::ObjectNotFoundError
        #do nothing - just proceed
      end
      klass.new(:pid => pid).tap do |object|
        yield object
      end
    end

    #If the specified object exists in fedora then delete it
    def delete_if_exists(pid, klass = Medusa::GenericObject)
      begin
        object = klass.find(pid)
      rescue ActiveFedora::ObjectNotFoundError
        return
      end
      object.delete if object and not object.new_object?
    end

    #return a Nokogiri::XML::Document on the file contents
    def file_to_xml(file)
      Nokogiri::XML::Document.parse(File.read(file))
    end

    def ingest
      raise NotImplementedError, "Subclass responsibility"
    end

    def add_xml_datastream(object, dsid, bytes, options = {})
      add_managed_binary_datastream(object, dsid, bytes, options.reverse_merge(:contentType => 'text/xml'))
    end

    def add_mods_and_dc(object, mods_file_name)
      add_xml_datastream_from_file(object, 'MODS', mods_file_name)
      add_xml_datastream(object, 'DC', Medusa::ModsToDublinCoreConverter.instance.dc_from_mods_file_and_object(mods_file_name, object).to_s)
    end


    def add_xml_datastream_from_file(object, dsid, file, options = {})
      contents = File.open(file, 'r:binary') { |f| f.read }
      add_xml_datastream(object, dsid, contents, options)
    end

    def add_managed_binary_datastream(object, dsid, bytes, options = {})
      object.create_datastream(ActiveFedora::Datastream, dsid,
                               options.reverse_merge(:controlGroup => 'M', :dsLabel => dsid,
                                                     :contentType => 'application/octet-stream', :checksumType => 'SHA-1')).tap do |datastream|
        datastream.content = bytes
        object.add_datastream(datastream)
      end
    end

    def add_managed_datastream_from_file(object, dsid, file, options = {})
      bytes = File.open(file, 'r:binary') { |f| f.read }
      add_managed_binary_datastream(object, dsid, bytes, options)
    end

    #return an array of all subdirectories of the given directory except for . and ..
    def subdirs(dir)
      Dir["#{dir}/*"].select { |d| File.directory?(d) } - ['.', '..']
    end

    #answer true if dir has no subdirectories and false otherwise
    def leaf_directory?(dir)
      subdirs(dir).empty?
    end

  end
end

#test to try to resolve DX problem
module ActiveFedora
  class Datastream
    alias original_save save

    #def save
    #  puts "Sleeping before saving #{pid} #{dsid}"
    #  sleep 15
    #  puts "Attempting save"
    #  original_save
    #end
  end
end