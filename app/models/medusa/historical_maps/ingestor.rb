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
        do_if_new_object(pid, Medusa::Parent) do |item|
          add_metadata(item, 'PREMIS', premis_file)
          add_metadata(item, 'MODS', mods_file)
          add_metadata(item, 'CONTENT_DM_MD', content_dm_file, true)
          add_metadata(item, 'MODS_FROM_MARC', mods_from_marc_file, true)
          add_metadata(item, 'CONTENT_DM_CPD', cpd_file, true)
        end
      end

      #If file_data is true, take the data in the file file_data[:original] and put it into an XML metadata stream
      #on the given object with stream_name as the dsId.
      #If file_data is false, then if allow_skip is true just skip adding this stream. If allow_skip is false (the default)
      #then an error should be raised.
      def add_metadata(object, stream_name, file_data, allow_skip = false)
        add_xml_datastream_from_file(object, stream_name, file_data[:original]) if file_data or !allow_skip
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
          add_metadata(asset, 'PREMIS', premis_file)
        end
      end

    end
  end
end