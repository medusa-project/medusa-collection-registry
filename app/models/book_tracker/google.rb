module BookTracker

  ##
  # Checks Google for bibliographic data and updates the corresponding local
  # items with its findings.
  #
  class Google < Service

    def self.check_in_progress?
      Task.where(service: Service::GOOGLE).
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
    end

    def check
      # https://developers.google.com/books/docs/v1/using#PerformingSearch
      # https://developers.google.com/books/docs/v1/using#APIKey

      if Filesystem.import_in_progress? or Service.check_in_progress?
        raise 'Cannot check Google while another import or service check is '\
        'in progress.'
      end

      task = Task.create!(name: 'Checking Google',
                          service: Service::GOOGLE)

      begin
        # TODO: write this
      rescue Interrupt => e
        task.name = 'Google check aborted'
        task.status = Status::FAILED
        task.save!
        raise e
      rescue => e
        task.name = "Google check failed: #{e}"
        task.status = Status::FAILED
        task.save!
        raise e
      else
        task.name = "Checking Google: Updated database with "\
        "#{items_in_google} found items."
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

  end

end
