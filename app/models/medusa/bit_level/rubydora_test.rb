module Medusa
  module BitLevel

    module RubydoraTest

      module_function

      def ingest(source_directory, opts = {})
        Rails.logger.info("Rubydora Bit Ingesting Directory #{source_directory}")
        connection = ActiveFedora::Base.connection_for_pid('any_pid_here:1')
        #make source directory object
        name = ::File.basename(source_directory)
        #directory = connection.create(pid(name))
        directory = Rubydora::DigitalObject.new(pid(name), connection)
        directory.save
        add_properties_datastream(directory, name)
        Rails.logger.info("Rubydora ingested directory: #{pid(name)}")
        #ingest source files
        source_files = Dir[File.join(source_directory, '*')].sort
        source_files.each do |filename|
          name = ::File.basename(filename)
          #file = connection.create(pid(name))
          file = Rubydora::DigitalObject.new(pid(name), connection)
          #file.add_relationship('has_directory', directory)
          file.save
          add_properties_datastream(file, name)
          content = File.open(filename, 'rb') { |f| f.read }
          add_content_datastream(file, content)
          Rails.logger.info("Rubydora ingested file: #{pid(name)}")
        end
      end

      def export(target_directory, source_directory)
        Rails.logger.info("Rubydora bit exporing Directory #{source_directory}")
        connection = ActiveFedora::Base.connection_for_pid('any_pid_here:1')
        FileUtils.mkdir_p(target_directory)
        source_files = Dir[File.join(source_directory, '*')].sort
        source_files.each do |filename|
          name = ::File.basename(filename)
          object = connection.find(pid(name))
          content = object.datastream['CONTENT'].content
          File.open(File.join(target_directory, name), 'wb') {|f| f.write content}
          Rails.logger.info("Rubydora exported file: #{pid(name)}")
        end
      end

      def clear(source_directory)
        Rails.logger.info("Rubydora Bit Clearing Directory #{source_directory}")
        connection = ActiveFedora::Base.connection_for_pid('any_pid_here:1')
        #make source directory object
        name = ::File.basename(source_directory)
        source_files = Dir[File.join(source_directory, '*')].sort
        source_files.each do |filename|
          name = ::File.basename(filename)
          begin
            obj = Rubydora::DigitalObject.new(pid(name), connection)
            obj.delete unless obj.new?
            Rails.logger.info("Rubydora deleted #{pid(name)}")
          rescue RestClient::ResourceNotFound
            #expected - do nothing
          end
        end
        true
      end

      def properties_xml(name)
        <<-XML
        <properties>
          <name>#{name}</name>
        </properties>
        XML
      end

      def pid(name)
        "rubydora-test:#{name}"
      end

      def add_properties_datastream(object, name)
        properties = object.datastream['PROPERTIES']
        properties.content = properties_xml(name)
        properties.save
      end

      def add_content_datastream(object, content)
        datastream = object.datastream['CONTENT']
        datastream.content = content
        datastream.controlGroup = 'M'
        datastream.dsLabel = 'CONTENT'
        datastream.mimeType = 'application/octet-stream'
        datastream.checksumType = 'SHA-1'
        datastream.save
      end

    end
  end
end
