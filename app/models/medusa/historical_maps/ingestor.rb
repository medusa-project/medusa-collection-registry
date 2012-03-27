module Medusa
  module HistoricalMaps
    class Ingestor < Medusa::ContentDmIngestor

      def ingest
        fedora_collection = ingest_collection
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