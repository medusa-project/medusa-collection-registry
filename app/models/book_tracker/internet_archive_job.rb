module BookTracker

  ##
  # DelayedJob that checks Internet Archive for bibliographic data and updates
  # the corresponding local items with its findings.
  #
  class InternetArchiveJob < Struct.new(:a)

    QUEUE_NAME = 'book_tracker'

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
      InternetArchive.new.check
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
      self.error(job, 'Unknown Delayed::Job failure')
    end

    private

    def current_task
      Task.where(service: Service::INTERNET_ARCHIVE).order(created_at: :desc).first
    end

  end

end
