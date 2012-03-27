#This is intended to be mixed in to an Ingestor (and depends on some stuff in Ingestors, like the package root)
#It is to encapsulate some things common to our ContentDm ingests
module Medusa
  class ContentDmIngestor < GenericIngestor
    #parse the filename, returning a hash which has components for:
    #:pid -> unique id for this content, suitable for medusa pid after small transformation (which we do here)
    #:extension -> extension of filename
    #:base -> rest of the filename. This may be further parseable, but not by this method
    #:dir -> directory where the file lies
    #:original - the original filename
    def parse_filename(filename)
      Hash.new.tap do |h|
        h[:original] = filename
        h[:dir] = File.dirname(filename)
        h[:extension] = File.extname(filename)
        parts = File.basename(filename, h[:extension]).split('_')
        uid = parts.pop
        namespace = parts.pop
        h[:pid] = "#{namespace}:#{uid}"
        h[:base] = parts.join('_')
      end
    end

    def collection_file_data
      files = Dir[File.join(self.package_root, 'collection', '*.*')]
      files.collect { |f| parse_filename(f) }
    end

    def item_dirs
      Dir[File.join(self.package_root, '*', '*', '*')]
    end

    def item_file_data(item_dir)
      files = Dir[File.join(item_dir, '*.*')]
      files.collect { |f| parse_filename(f) }
    end

    def uningest
      collection_files = self.collection_file_data
      collection_premis_file = collection_files.detect { |f| f[:base] == 'premis_object' }
      collection_pid = collection_premis_file[:pid]
      collection = Medusa::Set.load_instance(collection_pid)
      collection.recursive_delete
    end

    def ingest_collection
      collection_files = self.collection_file_data
      collection_premis_file = collection_files.detect { |f| f[:base] == 'premis_object' }
      collection_mods_file = collection_files.detect { |f| f[:base] == 'mods' }
      collection_pid = collection_premis_file[:pid]
      puts "INGESTING COLLECTION: " + collection_pid
      fedora_collection = do_if_new_object(collection_pid, Medusa::Set) do |collection_object|
        add_xml_datastream_from_file(collection_object, 'PREMIS', collection_premis_file[:original])
        add_xml_datastream_from_file(collection_object, 'MODS', collection_mods_file[:original])
        collection_object.save
      end
      puts "INGESTED COLLECTION: #{collection_pid}"
      return fedora_collection
    end

  end
end