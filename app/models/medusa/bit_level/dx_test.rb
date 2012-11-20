require 'net/http'
module Medusa
  module BitLevel

    module DxTest

      module_function

      def ingest(source_directory)
        Rails.logger.info("DX Ingesting Directory #{source_directory}")
        #ingest source files
        source_files = Dir[::File.join(source_directory, '*')].sort
        client = get_client
        source_files.each do |filename|
          ingest_file(client, filename)
        end
      end

      def ingest_file(client, filename)
        content = ::File.open(filename, 'rb') { |f| f.read }
        client.post(file_url(filename), content, {'Host' => 'medusa.grainger.illinois.edu',
                                                  'Content-Type' => 'text/plain',
                                                  'Content-MD5' => Digest::MD5.file(filename).base64digest})
        Rails.logger.info("DX ingested file: #{filename}")
      rescue Exception => e
        Rails.logger.error "#{e} raised ingesting #{filename}. Retrying."
        ingest_file(client, filename)
      end

      def export(source_directory, target_directory)
        Rails.logger.info("DX bit exporing Directory #{source_directory}")
        FileUtils.mkdir_p(target_directory)
        source_files = Dir[::File.join(source_directory, '*')].sort
        client = get_client
        source_files.each do |filename|
          export_file(client, filename, target_directory)
        end
      end

      def export_file(client, filename, target_directory)
        response = client.get(file_url(filename), [], nil, 'Host' => 'medusa.grainger.illinois.edu')
        ::File.open(::File.join(target_directory, ::File.basename(filename)), 'wb') do |f|
          f.write response.body
        end
        Rails.logger.info("DX exported file: #{filename}")
      rescue Exception => e
        Rails.logger.error "#{e} raised exporting #{filename}. Retrying."
        export_file(client, filename, target_directory)
      end

      def file_url(filename)
        "http://libstor.grainger.illinois.edu/test/info:fedora/ingest-test/#{filename}"
      end

      def clear(source_directory)
        Rails.logger.info("DX Bit Clearing Directory #{source_directory}")
        source_files = Dir[::File.join(source_directory, '*')].sort
        client = get_client
        source_files.each do |filename|
          clear_file(client, filename)
        end
      end

      def clear_file(client, filename)
        client.delete(file_url(filename), {}, 'Host' => 'medusa.grainger.illinois.edu')
        Rails.logger.info("DX Bit cleared #{filename}")
      rescue Exception => e
        Rails.logger.error "#{e} raised clearing #{filename}. Retrying."
        clear_file(client, filename)
      end

      def get_client
        config = dx_test_config
        Mechanize.new.tap do |agent|
          hosts = (70..71).collect { |x| (49..54).collect { |y| "http://172.22.#{x}.#{y}" } }.flatten << 'http://libstor.grainger.illinois.edu'
          hosts.each { |host| agent.add_auth(host, config['user'], config['password']) }
        end
      end

      def dx_test_config
        YAML.load_file(::File.join(Rails.root, 'config', 'dx_test.yml'))
      end

      def make_test_file(filename, size)
        letters = ('a'..'z').to_a + ('A'..'Z').to_a
        File.open(filename, 'w') do |f|
          while size > 0
            line_size = [79, size-1].min
            size -= (line_size + 1)
            line = line_size.times.collect {letters.sample}
            f.puts line.join('')
          end
        end
      end

    end
  end
end
