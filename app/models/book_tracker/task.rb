module BookTracker

  class Task < ActiveRecord::Base

    after_initialize :init
    before_save :constrain_progress, :auto_complete

    def init
      self.status ||= Status::RUNNING
    end

    def auto_complete
      if (1 - self.percent_complete).abs <= 0.0000001
        self.status = Status::SUCCEEDED
        self.completed_at = Time.current
      end
    end

    def constrain_progress
      self.percent_complete = self.percent_complete < 0 ? 0 : self.percent_complete
      self.percent_complete = self.percent_complete > 1 ? 1 : self.percent_complete
    end

    def status=(status)
      write_attribute(:status, status)
      if status == Status::SUCCEEDED
        self.percent_complete = 1
        self.completed_at = Time.current
      end
    end

  end

end
