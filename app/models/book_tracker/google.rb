module BookTracker

  ##
  # Checks Google for bibliographic data using Google GRIN, and updates the
  # corresponding local items with its findings.
  #
  # Access to GRIN is limited by IP address. If a request to
  # https://books.google.com/libraries/UIUC/ returns HTTP 403, contact Jon G.
  # in Library IT to request access.
  #
  class Google

    def self.check_in_progress?
      Task.where(service: Service::GOOGLE).
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
    end

    def check
      if Filesystem.import_in_progress? or Service.check_in_progress?
        raise 'Cannot check Google while another import or service '\
        'check is in progress.'
      end

      task = Task.create!(name: 'Checking Google', service: Service::GOOGLE)
      puts task.name

      begin
        bt_items_in_gb = 0
        new_bt_items_in_gb = 0

        uri = URI.parse('https://books.google.com/libraries/UIUC/_all_books?format=text&mode=all')
        request = Net::HTTP::Get.new(uri.path)
        response = Net::HTTP.start(uri.host, uri.port,
                                   use_ssl: uri.scheme == 'https',
                                   verify_mode: OpenSSL::SSL::VERIFY_NONE) do |https|
          https.request(request)
        end
        raise "Server returned HTTP #{response.code}." unless
            response.kind_of?(Net::HTTPOK)

        # Response body columns: [0] barcode, [1] scanned date,
        # [2] processed date, [3] analyzed date, [4] converted date,
        # [5] downloaded date
        # Dates are in the form yyyy-mm-dd hh:mm
        response.body.split("\n").each_with_index do |line, index|
          item = Item.find_by_obj_id(line.split("\t")[0].strip)
          if item
            unless item.exists_in_google
              item.exists_in_google = true
              item.save!
              new_bt_items_in_gb += 1
            end
            bt_items_in_gb += 1
          end

          if index % 1000 == 0
            task.percent_complete = (index + 1).to_f / response.body.length.to_f
            task.save!
          end
        end
      rescue SystemExit, Interrupt => e
        task.name = "Google check failed: #{e}"
        task.status = Status::FAILED
        task.save!
        puts task.name
        raise e
      rescue => e
        task.name = "Google check failed: #{e}"
        task.status = Status::FAILED
        task.save!
        puts task.name
      else
        task.name = "Checking Google: Updated database with #{new_bt_items_in_gb} "\
        "new items out of #{bt_items_in_gb} total book tracker items in Google."
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

  end

end
