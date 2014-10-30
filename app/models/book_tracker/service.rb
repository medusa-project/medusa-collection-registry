module BookTracker

  class Service

    HATHITRUST = 0
    INTERNET_ARCHIVE = 1
    GOOGLE = 2
    LOCAL_STORAGE = 3

    def self.check_in_progress?
      Filesystem.import_in_progress? or Hathitrust.check_in_progress? or
          InternetArchive.check_in_progress? or Google.check_in_progress?
    end

  end

end
