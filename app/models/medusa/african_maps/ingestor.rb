module Medusa
  module AfricanMaps
    class Ingestor < Medusa::ContentDmIngestor

      def build_parent(dir)
        pid = File.basename(dir) == self.item_pid ? self.item_pid : "#{self.item_pid}.#{File.basename(dir)}"
        puts "INGESTING PARENT #{pid}"
        files = self.file_data(dir)
        premis_file = files.detect { |f| f[:base] == 'premis' }
        mods_file = files.detect { |f| f[:base] == 'mods' }
        content_dm_file = files.detect { |f| f[:base] == 'contentdm' }
        marc_file = files.detect { |f| f[:base] == ('opac') }
        do_if_new_object(pid, Medusa::Parent) do |item|
          add_metadata(item, 'PREMIS', premis_file)
          add_mods_and_dc(item, mods_file[:original]) if mods_file
          add_metadata(item, 'CONTENT_DM_MD', content_dm_file, true)
          add_metadata(item, 'MODS_FROM_MARC', marc_file, true)
        end
      end

      def build_asset(dir)
        files = file_data(dir)
        premis_file = files.detect { |f| f[:base] == 'premis' }
        image_file = files.detect { |f| f[:base] == 'image' }
        mime_type = image_file[:extension].downcase == '.jp2' ? 'image/jp2' : 'image/jpeg'
        asset_pid = image_file[:pid]
        puts "INGESTING ASSET: #{asset_pid}"
        do_if_new_object(asset_pid, Medusa::Asset) do |asset|
          add_managed_datastream_from_file(asset, 'IMAGE', image_file[:original], :mimeType => mime_type)
          add_metadata(asset, 'PREMIS', premis_file)
        end
      end

    end
  end
end