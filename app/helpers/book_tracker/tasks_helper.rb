module BookTracker
  module TasksHelper

    def bootstrap_class_for_status(status)
      case status
        when Status::SUCCEEDED
          'text-success'
        when Status::FAILED
          'text-danger'
        when Status::RUNNING
          'text-primary'
        when Status::PAUSED
          'text-info'
      end
    end

  end
end
