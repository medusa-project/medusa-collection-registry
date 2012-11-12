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
        fedora_file = self.new(:pid => self.random_pid)
        fedora_file.add_relationship(:has_directory, medusa_directory)
        content_datastream = fedora_file.create_datastream(ActiveFedora::Datastream, 'CONTENT',
                                                           :controlGroup => 'M', :dsLabel => ::File.basename(source_file),
                                                           :contentType => 'application/octet-stream',
                                                           :checksumType => 'SHA-1', :blob => ::File.new(source_file))
        fedora_file.add_datastream(content_datastream)
        fedora_file.name = ::File.basename(source_file)
        fedora_file.save
      end

    end
  end
end