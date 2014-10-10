module BookTracker

  class Service

    HATHITRUST = 0
    INTERNET_ARCHIVE = 1
    GOOGLE = 2
    LOCAL_STORAGE = 3

    def self.check_in_progress?
      HathitrustJob.check_in_progress? or InternetArchiveJob.check_in_progress?
    end

  end

end
