module Medusa
  module BitLevel
    class File < Medusa::Object
      has_relationship 'directory', :has_directory

      has_metadata :name => 'properties', :type => NameProperties

      def name
        self.properties.name
      end

      def name=(name)
        self.properties.name = name
      end

      def self.ingest(source_file, medusa_directory)
        Rails.logger.info("Bit Ingesting File #{source_file}")
        fedora_file = self.new(:pid => self.random_pid)
        fedora_file.add_relationship(:has_directory, medusa_directory)
        #need to omit from 0 size files
        if ::File.size?(source_file)
          content_datastream = fedora_file.create_datastream(ActiveFedora::Datastream, 'CONTENT',
                                                             :controlGroup => 'M', :dsLabel => 'CONTENT',
                                                             :contentType => 'application/octet-stream',
                                                             :checksumType => 'SHA-1', :blob => ::File.new(source_file, 'rb'))
          fedora_file.add_datastream(content_datastream)
        end
        fedora_file.name = ::File.basename(source_file)
        fedora_file.save
      end

      def has_content?
        self.datastreams['CONTENT']
      end

      def content
        if self.has_content?
          self.datastreams['CONTENT'].content
        else
          nil
        end
      end

    end
  end
end