module BookTracker

  ##
  # Checks Internet Archive for bibliographic data and updates the
  # corresponding local items with its findings.
  #
  class InternetArchive

    def self.check_in_progress?
      Task.where(service: Service::INTERNET_ARCHIVE).
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
    end

    def check
      if Filesystem.import_in_progress? or Service.check_in_progress?
        raise 'Cannot check Internet Archive while another import or service '\
        'check is in progress.'
      end

      task = Task.create!(name: 'Checking Internet Archive',
                          service: Service::INTERNET_ARCHIVE)

      begin
        doc = get_api_results(task)

        items_in_ia = 0
        num_items = doc.xpath('//result/@numFound').first.content.to_i

        task.name = 'Checking Internet Archive: Scanning the inventory for '\
        'UIU records...'
        task.save!
        puts task.name

        doc.xpath('//result/doc/str').each_with_index do |node, index|
          item = Item.find_by_ia_identifier(node.content)
          if item
            item.exists_in_internet_archive = true
            item.save!
            items_in_ia += 1
          end

          if index % 500 == 0
            task.percent_complete = (index + 1).to_f / num_items.to_f
            task.save!
          end
        end
      rescue SystemExit, Interrupt => e
        task.name = "Internet Archive check failed: #{e}"
        task.status = Status::FAILED
        task.save!
        puts task.name
        raise e
      rescue => e
        task.name = "Internet Archive check failed: #{e}"
        task.status = Status::FAILED
        task.save!
        puts task.name
        raise e
      else
        task.name = "Checking Internet Archive: Updated database with "\
        "#{items_in_ia} found items."
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

    private

    ##
    # Gets all UIUC records from IA, downloading and caching them if necessary,
    # or returning the current date's cached copy if available.
    #
    # @return [Nokogiri::XML::Document]
    #
    def get_api_results(task)
      expected_filename = "ia_results_#{Date.today.strftime('%Y%m%d')}.xml"
      cache_pathname = Rails.root.join('public', 'system', 'book_tracker')
      expected_pathname = File.join(cache_pathname, expected_filename)

      unless File.exists?(expected_pathname)
        # Delete older downloads
        Dir.glob(File.join(cache_pathname, 'ia_results_*')).
            each{ |f| File.delete(f) }

        task.name = 'Checking Internet Archive: Downloading UIUC inventory'
        task.save!
        puts task.name

        # https://archive.org/advancedsearch.php
        start_date = '1980-01-01'
        end_date = Date.today.strftime('%Y-%m-%d')
        uri = URI.parse("https://archive.org/advancedsearch.php?"\
            "q=mediatype:texts+updatedate:[#{start_date}+TO+#{end_date}]&"\
            "fl[]=identifier&rows=9999999&page=1&output=xml&save=yes%20"\
            "contributor:%22University%20of%20Illinois%20Urbana-Champaign")

        FileUtils.mkdir_p(cache_pathname)
        begin
          puts "Getting #{uri}"
          Net::HTTP.get_response(uri) do |res|
            res.read_body do |chunk|
              File.open(expected_pathname, 'ab') do |file|
                file.write(chunk)
              end
            end
          end
        rescue => e
          puts "#{e}"
          File.delete(expected_pathname) if File.exists?(expected_pathname)
          raise e
        end
      end
      File.open(expected_pathname) { |f| Nokogiri::XML(f) }
    end

  end

end
