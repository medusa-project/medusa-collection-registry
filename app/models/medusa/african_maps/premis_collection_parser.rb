module Medusa
  module AfricanMaps
    class PremisCollectionParser < PremisParser

      def parse
        PremisCollection.new.tap do |collection|
          collection.premis_file = self.premis_file
          collection.medusa_id = self.medusa_id
          collection.mods_file = expand_path(self.mods_file)
        end
      end

      def mods_file
        related_id('METADATA', 'HAS_ROOT', 'FILENAME')
      end

    end
  end
end