module Medusa
  module HistoricalMaps
    class Ingestor < Medusa::ContentDmIngestor

      #build and return, but do not yet save, parent object. Caller is responsible for setting up relationships and then saving
      def build_parent(dir)
        pid = File.basename(dir).sub('_', ':')
        puts "INGESTING PARENT #{pid}"
        files = self.file_data(dir)
        premis_file = files.detect { |f| f[:base] == 'premis' }
        mods_file = files.detect { |f| f[:base] == 'mods' }
        content_dm_file = files.detect { |f| f[:base] == 'contentdm' }
        mods_from_marc_file = files.detect { |f| f[:base].match('mods_') }
        cpd_file = files.detect { |f| f[:extension] == 'cpd' }
        do_if_new_object(pid, Medusa::Parent) do |item_object|
          add_xml_datastream_from_file(item_object, 'PREMIS', premis_file[:original])
          add_xml_datastream_from_file(item_object, 'MODS', mods_file[:original])
          add_xml_datastream_from_file(item_object, 'CONTENT_DM_MD', content_dm_file[:original]) if content_dm_file
          add_xml_datastream_from_file(item_object, 'MODS_FROM_MARC', mods_from_marc_file[:original]) if mods_from_marc_file
          add_xml_datastream_from_file(item_object, 'CONTENT_DM_CPD', cpd_file[:original]) if cpd_file
        end
      end

      #build and return, but do not save, a new asset on the given directory
      def build_asset(dir)
        files = file_data(dir)
        premis_file = files.detect { |f| f[:base] == 'premis' }
        image_file = files.detect { |f| f[:base] == 'image' }
        mime_type = image_file[:extension] == 'jp2' ? 'image/jp2' : 'image/jpeg'
        asset_pid = image_file[:pid]
        puts "INGESTING ASSET: #{asset_pid}"
        do_if_new_object(asset_pid, Medusa::Asset) do |asset|
          add_managed_datastream_from_file(asset, 'IMAGE', image_file[:original], :mimeType => mime_type)
          add_xml_datastream_from_file(asset, 'PREMIS', premis_file[:original])
        end
      end

    end
  end
end