module BookTracker

  ##
  # DelayedJob that checks Internet Archive for bibliographic data and updates
  # the corresponding local items with its findings.
  #
  class InternetArchiveJob < Struct.new(:a)

    QUEUE_NAME = 'book_tracker:internet_archive'

    def self.check_in_progress?
      Delayed::Job.where(queue: QUEUE_NAME).where('locked_by IS NOT NULL').any?
    end

    ##
    # For delayed_job
    #
    def max_attempts
      1
    end

    ##
    # For delayed_job
    #
    def queue_name
      QUEUE_NAME
    end

    def perform
      if ImportJob.import_in_progress? or Service.check_in_progress?
        raise 'Cannot check HathiTrust while another import or service check is '\
        'in progress.'
      end

      last_successful_task = Task.
          where(service: Service::INTERNET_ARCHIVE).
          where(status: Status::SUCCEEDED).
          order(completed_at: :desc).limit(1).first
      start_date = last_successful_task ?
          last_successful_task.completed_at.strftime('%Y-%m-%d') : '1980-01-01'
      end_date = Date.today.strftime("%Y-%m-%d")

      task_name = "Checking Internet Archive "
      if last_successful_task
        task_name += "for items added between #{start_date} (the date of the "\
        "last check) and #{end_date}"
      else
        task_name += "with no date constraint"
      end
      task = Task.create!(name: task_name,
                          service: Service::INTERNET_ARCHIVE)
      puts task.name

      items_in_ia = 0

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

      task.name += ": Updated database with #{items_in_ia} found items."
      task.status = Status::SUCCEEDED
      task.save!
      puts task.name
    end

    ##
    # delayed_job hook
    #
    def error(job, exception)
      task = current_task
      task.name = "Internet Archive check failed: #{exception}"
      task.status = Status::FAILED
      task.save!
    end

    ##
    # delayed_job hook
    #
    def failure(job)
      task = current_task
      task.name = "HathiTrust check failed"
      task.status = Status::FAILED
      task.save!
    end

    private

    def current_task
      Task.where(service: Service::INTERNET_ARCHIVE).order(created_at: :desc).first
    end

  end

end
