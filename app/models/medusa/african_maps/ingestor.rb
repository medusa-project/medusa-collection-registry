module Medusa
  module AfricanMaps
    class Ingestor < Medusa::GenericIngestor

      def ingest
        #ingest collection
        #create collection object
        #attach metadata streams
        premis_collection = PremisCollectionParser.new(File.join(self.package_root, 'collection', 'premis.xml')).parse
        puts "INGESTING COLLECTION: |#{premis_collection.medusa_id}|"
        fedora_collection = with_fresh_object(premis_collection.medusa_id, Medusa::Set) do |collection_object|
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
          fedora_item = with_fresh_object(premis_item.medusa_id, Medusa::Parent) do |item_object|
            add_xml_datastream_from_file(item_object, 'PREMIS', premis_item.premis_file)
            add_xml_datastream_from_file(item_object, 'MODS', premis_item.mods_file)
            add_xml_datastream_from_file(item_object, 'CONTENT_DM_MD', premis_item.content_dm_file)
            add_xml_datastream_from_file(item_object, 'MARC', premis_item.marc_file) if premis_item.marc_file
            item_object.add_relationship(:is_member_of, fedora_collection)
            item_object.save
            #finally ingest the image file as another object - for now I give a pid that is the
            #item pid with ~image appended
            image_object_id = premis_item.medusa_id + "~image"
            with_fresh_object(image_object_id, Medusa::Part) do |image_object|
              add_managed_datastream_from_file(image_object, 'IMAGE', premis_item.image_file, :mimeType => 'image/jpeg')
              #image_object.add_relationship(:is_part_of, fedora_item)
              image_object.save
            end
          end
          puts "INGESTED ITEM: #{premis_item.medusa_id}"
        end
        puts ""
      end

    end
  end
end