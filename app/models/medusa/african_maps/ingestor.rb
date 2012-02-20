module Medusa
  module AfricanMaps
    class Ingestor < Medusa::GenericIngestor

      def ingest
        #ingest collection
        #create collection object
        #attach metadata streams
        premis_collection = PremisCollectionParser.new(File.join(self.package_root, 'collection', 'premis.xml')).parse
        puts "INGESTING COLLECTION: |#{premis_collection.medusa_id}|"
        fedora_collection = with_fresh_object(premis_collection.medusa_id, Medusa::AfricanMaps::Object) do |collection_object|
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
          #item = PremisItemParser.new(item_file).parse
          #puts "ITEM:"
          #puts "\tID: #{item.medusa_id}"
          #puts "\tCOLLECTION_ID: #{item.collection_id}"
          #puts "\tIMAGE: #{item.image_file}"
          #puts "\tMODS: #{item.mods_file}"
          #puts "\tPREMIS: #{item.premis_file}"
          #puts "\tCON_DM: #{item.content_dm_file}"
          #puts "\tMARC: #{item.marc_file}"
          #puts "\tIMAGE: #{item.image_file}"
          #puts ""
        end
      end

    end
  end
end