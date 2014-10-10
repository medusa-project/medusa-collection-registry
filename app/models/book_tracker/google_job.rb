module BookTracker

  ##
  # DelayedJob that checks Google for bibliographic data and updates the
  # corresponding local items with its findings.
  #
  class GoogleJob < Struct.new(:a)

    QUEUE_NAME = 'book_tracker:google'

    def self.check_in_progress?
      Task.where(service: Service::GOOGLE).
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
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
        raise 'Cannot check Google while another import or service '\
        'check is in progress.'
      end

      task = Task.create!(name: 'Checking Google',
                          service: Service::GOOGLE)
      puts task.name

      items_in_gb = 0

      uri = URI.parse('https://books.google.com/libraries/UIUC/_all_books?format=text&mode=all')
      response = Net::HTTP.get_response(uri)

      response.body.split("\n").each_with_index do |line, index|
        item = Item.find_by_obj_id(line.split("\t")[0].strip)
        if item
          item.exists_in_google = true
          item.save!
          items_in_gb += 1
        end

        if index % 500 == 0
          task.percent_complete = (index + 1).to_f / response.body.length.to_f
          task.save!
        end
      end

      task.name = "Checking Google: Updated database with #{items_in_gb} "\
      "found items."
      task.status = Status::SUCCEEDED
      task.save!
      puts task.name
    end

    ##
    # delayed_job hook
    #
    def error(job, exception)
      task = current_task
      task.name = "Google check failed: #{exception}"
      task.status = Status::FAILED
      task.save!
    end

    ##
    # delayed_job hook
    #
    def failure(job)
      task = current_task
      task.name = "Google check failed"
      task.status = Status::FAILED
      task.save!
    end

    private

    def current_task
      Task.where(service: Service::GOOGLE).order(created_at: :desc).first
    end

  end

end
