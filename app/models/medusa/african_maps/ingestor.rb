module Medusa
  module AfricanMaps
    class Ingestor < Medusa::GenericIngestor

      def ingest
        #ingest collection
        #create collection object
        #attach metadata streams
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
          item_pid = File.basename(item_dir).sub('_', ':')
          puts "INGESTING ITEM: #{item_pid}"
          item_files = self.item_file_data(item_dir)
          item_premis_file = item_files.detect {|f| f[:base] == 'premis'}
          item_mods_file = item_files.detect {|f| f[:base] == 'mods'}
          item_content_dm_file = item_files.detect {|f| f[:base] == 'contentdm'}
          item_mods_from_marc_file = item_files.detect {|f| f[:base].match('mods_')}
          item_image_file = item_files.detect {|f| f[:base] == 'image'}
          fedora_item = do_if_new_object(item_pid, Medusa::Parent) do |item_object|
            add_xml_datastream_from_file(item_object, 'PREMIS', item_premis_file[:original])
            add_xml_datastream_from_file(item_object, 'MODS', item_mods_file[:original])
            add_xml_datastream_from_file(item_object, 'CONTENT_DM_MD', item_content_dm_file[:original])
            add_xml_datastream_from_file(item_object, 'MODS_FROM_MARC', item_mods_from_marc_file[:original])
            item_object.add_relationship(:is_member_of, fedora_collection)
            item_object.save
          end
          asset_pid = item_image_file[:pid]
          puts "INGESTING ASSET: #{asset_pid}"
          fedora_asset = do_if_new_object(asset_pid, Medusa::Asset) do |asset|
            add_managed_datastream_from_file(asset, 'JP2', item_image_file[:original], :mimeType => 'image/jp2')
          end
          fedora_asset.add_relationship(:is_part_of, fedora_item)
          fedora_asset.save
          puts "INGESTED ASSET: #{asset_pid}"
          puts "INGESTED ITEM: #{item_pid}"
        end
        puts ""
      end

      #with relationships we should be able to simplify (and perhaps generalize) this
      #just start with the collection, recursively get all parents and file assets
      #and then blow them all away.
      #So really we just need to find the one collection pid and then away we go.
      def uningest
        collection_files = self.collection_file_data
        collection_premis_file = collection_files.detect { |f| f[:base] == 'premis_object' }
        collection_pid = collection_premis_file[:pid]
        collection = Medusa::Set.load_instance(collection_pid)
        collection.recursive_delete
      end

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
        files.collect {|f| parse_filename(f)}
      end

    end
  end
end