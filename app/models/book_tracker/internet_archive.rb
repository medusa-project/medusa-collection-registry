module BookTracker

  ##
  # Checks Internet Archive for bibliographic data and updates the
  # corresponding local items with its findings.
  #
  class InternetArchive

    QUEUE_NAME = 'book_tracker:internet_archive'

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

      start_date = '1980-01-01'
      end_date = Date.today.strftime("%Y-%m-%d")

      task = Task.create!(name: 'Checking Internet Archive: Downloading UIUC '\
      'inventory',
                          service: Service::INTERNET_ARCHIVE)
      puts task.name

      begin
        items_in_ia = 0

        # https://archive.org/advancedsearch.php
        uri = URI.parse("https://archive.org/advancedsearch.php?"\
        "q=mediatype:texts+updatedate:[#{start_date}+TO+#{end_date}]&"\
        "fl[]=identifier&rows=9999999&page=1&output=json&save=yes%20"\
        "contributor:%22University%20of%20Illinois%20Urbana-Champaign")
        body = open(uri, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE })
        json = JSON.parse(body.readlines.join(''))
        num_items = json['response']['docs'].length

        task.name = 'Checking Internet Archive: Scanning the inventory for '\
        'UIU records...'
        task.save!

        json['response']['docs'].each_with_index do |doc, index|
          item = Item.find_by_ia_identifier(doc['identifier'])
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
        task = current_task
        task.name = "Internet Archive check failed: #{e}"
        task.status = Status::FAILED
        task.save!
      else
        task.name = "Checking Internet Archive: Updated database with "\
        "#{items_in_ia} found items."
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

  end

end
