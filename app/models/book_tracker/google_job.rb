module BookTracker

  ##
  # DelayedJob that checks Google for bibliographic data and updates the
  # corresponding local items with its findings.
  #
  class GoogleJob < Struct.new(:a)

    QUEUE_NAME = 'book_tracker' # DelayedJob queue name

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
      Google.new.check
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
      self.error(job, 'Unknown Delayed::Job failure')
    end

    private

    def current_task
      Task.where(service: Service::GOOGLE).order(created_at: :desc).first
    end

  end

end
