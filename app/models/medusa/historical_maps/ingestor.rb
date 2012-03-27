module Medusa
  module HistoricalMaps
    class Ingestor < Medusa::ContentDmIngestor

      def ingest
        #ingest collection
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
        self.item_dirs.each do |item_dir|
          puts item_dir
          #for each item
          # - parse files in directory - note that xml and cpd are both extensions we need to look at
          # - make item object and attach to collection with metadata
          # - partition subdirectories into assets and children
          # - attach any assets - note that images have varying mime types here
          # - attach any child objects and recursively generate them
        end
      end

    end
  end
end