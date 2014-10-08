module BookTracker

  ##
  # Checks Internet Archive for bibliographic data and updates the corresponding
  # local items with its findings.
  #
  class InternetArchive < Service

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

      last_successful_task = Task.
          where(service: Service::INTERNET_ARCHIVE).
          where(status: Status::SUCCEEDED).
          order(completed_at: :desc).limit(1).first
      task = Task.create!(name: 'Checking Internet Archive',
                          service: Service::INTERNET_ARCHIVE)
      puts task.name

      begin
        items_in_ia = 0

        start_date = last_successful_task ?
            last_successful_task.completed_at.strftime('%Y-%m-%d') : '2009-01-01'
        end_date = Date.today.strftime("%Y-%m-%d")

        # https://archive.org/advancedsearch.php
        uri = URI.parse("https://archive.org/advancedsearch.php?q=mediatype:texts"\
        "%20updatedate:[#{start_date}%20TO%20#{end_date}]%20contributor:"\
        "%22University%20of%20Illinois%20Urbana-Champaign%22&fl[]=identifier"\
        "&rows=9999999&indent=no&fmt=json")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body)

        num_items = json['response']['docs'].length

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
      rescue Interrupt => e
        task.name = 'Internet Archive check aborted'
        task.status = Status::FAILED
        task.save!
        raise e
      rescue => e
        task.name = "Internet Archive check failed: #{e}"
        task.status = Status::FAILED
        task.save!
        raise e
      else
        task.name += ": Updated database with #{items_in_ia} found items."
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

  end

end
