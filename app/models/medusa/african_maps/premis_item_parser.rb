require 'lib/medusa/african_maps/premis_parser'
require 'lib/medusa/african_maps/premis_item'

module Medusa
  module AfricanMaps
    class PremisItemParser < PremisParser

      def parse
        PremisItem.new.tap do |item|
          item.premis_file = self.premis_file
          item.medusa_id = self.medusa_id
          item.collection_id = self.collection_id
          item.image_file = expand_path(self.image_file)
          item.mods_file = expand_path((mods = self.mods_file))
          item.content_dm_file = expand_path((content_dm = self.content_dm_file(mods)))
          item.marc_file = expand_path(self.marc_file(content_dm))
        end
      end

      def collection_id
        related_id('COLLECTION', 'IS_MEMBER_OF', 'LOCAL')
      end

      def content_dm_file(mods_file)
        source_file(mods_file)
      end

      def mods_file
        related_id('METADATA', 'HAS_ROOT', 'FILENAME')
      end

      def marc_file(content_dm_file)
        source_file(content_dm_file) rescue nil
      end

      def image_file
        related_id('BASIC_IMAGE_ASSET', 'PRODUCTION_MASTER', 'FILENAME')
      end

    end
  end
end