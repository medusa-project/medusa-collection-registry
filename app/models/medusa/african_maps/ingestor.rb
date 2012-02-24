module Medusa
  module AfricanMaps
    class Ingestor < Medusa::GenericIngestor

      def ingest
        #ingest collection
        #create collection object
        #attach metadata streams
        premis_collection = PremisCollectionParser.new(File.join(self.package_root, 'collection', 'premis.xml')).parse
        puts "INGESTING COLLECTION: |#{premis_collection.medusa_id}|"
        fedora_collection = do_if_new_object(premis_collection.medusa_id, Medusa::Set) do |collection_object|
          add_xml_datastream_from_file(collection_object, 'PREMIS', premis_collection.premis_file)
          add_xml_datastream_from_file(collection_object, 'MODS', premis_collection.mods_file)
          collection_object.save
        end
        puts "INGESTED COLLECTION: #{premis_collection.medusa_id}"

        #ingest each item in collection
        ## create item object
        ## attach to collection
        ## attach metadata streams
        ## create image object
        ## attach to item
        ## attach image stream - no separate metadata
        Dir[File.join(self.package_root, '*', '*', 'premis.xml')].each do |item_file|
          premis_item = PremisItemParser.new(item_file).parse
          puts "INGESTING ITEM: #{premis_item.medusa_id}"
          fedora_item = do_if_new_object(premis_item.medusa_id, Medusa::Parent) do |item_object|
            add_xml_datastream_from_file(item_object, 'PREMIS', premis_item.premis_file)
            add_xml_datastream_from_file(item_object, 'MODS', premis_item.mods_file)
            add_xml_datastream_from_file(item_object, 'CONTENT_DM_MD', premis_item.content_dm_file)
            add_xml_datastream_from_file(item_object, 'MARC', premis_item.marc_file) if premis_item.marc_file
            item_object.add_relationship(:is_member_of, fedora_collection)
            item_object.save
          end
          #finally ingest the image file as another object - for now I give a pid that is the
          #item pid with ~image appended
          fedora_image = do_if_new_object(image_pid(premis_item), Medusa::Part) do |image_object|
            add_managed_datastream_from_file(image_object, 'IMAGE', premis_item.image_file, :mimeType => 'image/jpeg')
          end
          fedora_image.add_relationship(:is_part_of, fedora_item)
          fedora_image.save
          puts "INGESTED ITEM: #{premis_item.medusa_id}"
        end
        puts ""
      end

      def uningest
        ActiveFedora.init
        Dir[File.join(self.package_root, '*', '*', 'premis.xml')].each do |item_file|
          premis_item = PremisItemParser.new(item_file).parse
          delete_if_exists(image_pid(premis_item), Medusa::Part)
          delete_if_exists(premis_item.medusa_id, Medusa::Parent)
        end
        premis_collection = PremisCollectionParser.new(File.join(self.package_root, 'collection', 'premis.xml')).parse
        delete_if_exists(premis_collection.medusa_id, Medusa::Set)
      end

      def image_pid(premis_item)
        premis_item.medusa_id + "~image"
      end

    end
  end
end