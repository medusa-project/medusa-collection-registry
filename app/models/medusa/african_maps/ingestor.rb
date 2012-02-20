module Medusa
  module AfricanMaps
    class Ingestor < Medusa::GenericIngestor

      def ingest
        #ingest collection
        #create collection object
        #attach metadata streams
        collection = PremisCollectionParser.new(File.join(self.package_root, 'collection', 'premis.xml')).parse
        puts "INGESTING COLLECTION: |#{collection.medusa_id}|"
        fedora_collection = nil
        replacing_object(collection.medusa_id, Medusa::AfricanMaps::Object) do
          fedora_collection = Medusa::AfricanMaps::Object.new(:pid => collection.medusa_id)
          premis = fedora_collection.create_datastream(ActiveFedora::NokogiriDatastream, 'PREMIS', :controlGroup => 'X')
          premis.content =  File.open(collection.premis_file).read
          fedora_collection.add_datastream(premis)
          fedora_collection.save
        end
        puts "INGESTED COLLECTION: #{collection.medusa_id}"

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