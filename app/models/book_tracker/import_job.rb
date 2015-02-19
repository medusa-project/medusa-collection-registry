module BookTracker

  ##
  # DelayedJob that recursively scans a given directory for MARCXML records to
  # import, and imports them.
  #
  class ImportJob < Struct.new(:a)

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
      Filesystem.new.import
    end

    ##
    # delayed_job hook
    #
    def error(job, exception)
      task = current_task
      task.name = "Import failed: #{exception}"
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
      Task.where(service: Service::LOCAL_STORAGE).order(created_at: :desc).first
    end

  end

end
