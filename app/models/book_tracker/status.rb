module BookTracker

  ##
  # An enum-like class.
  #
  class Status

    WAITING = 0
    RUNNING = 1
    PAUSED = 2
    SUCCEEDED = 3
    FAILED = 4

    ##
    # @param status One of the Status constants
    # @return Human-readable status
    #
    def self.to_s(status)
      case status
        when Status::WAITING
          'Waiting'
        when Status::RUNNING
          'Running'
        when Status::PAUSED
          'Paused'
        when Status::SUCCEEDED
          'Succeeded'
        when Status::FAILED
          'Failed'
      end
    end

  end

end
