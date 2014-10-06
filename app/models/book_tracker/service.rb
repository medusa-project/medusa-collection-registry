module BookTracker

  ##
  # Abstract superclass from which all services should inherit.
  #
  class Service

    HATHITRUST = 0
    INTERNET_ARCHIVE = 1
    GOOGLE = 2

    def self.check_in_progress?
      Hathitrust.check_in_progress? or InternetArchive.check_in_progress?
    end

    ##
    # @param status One of the Service constants
    # @return Human-readable service
    #
    def self.to_s(service)
      case service
        when Service::GOOGLE
          'Google'
        when Service::HATHITRUST
          'HathiTrust'
        when Service::INTERNET_ARCHIVE
          'Internet Archive'
      end
    end

    def check
      raise NotImplementedError, 'Must override check()'
    end

  end

end
