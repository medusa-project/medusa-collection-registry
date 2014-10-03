module BookTracker

  class Task < ActiveRecord::Base

    after_initialize :init
    after_create :assign_pid
    before_save :constrain_progress, :auto_complete, :update_pid

    def init
      self.status ||= Status::RUNNING
    end

    def assign_pid
      self.pid = Process.pid if self.status == Status::RUNNING
      self.save!
    end

    def auto_complete
      if (1 - self.percent_complete).abs <= 0.0000001
        self.status = Status::SUCCEEDED
        self.completed_at = Time.now
      end
    end

    def update_pid
      self.pid = nil if self.status != Status::RUNNING
    end

    def constrain_progress
      self.percent_complete = self.percent_complete < 0 ? 0 : self.percent_complete
      self.percent_complete = self.percent_complete > 1 ? 1 : self.percent_complete
    end

    def status=(status)
      write_attribute(:status, status)
      if status == Status::SUCCEEDED
        self.percent_complete = 1
        self.completed_at = Time.now
      end
    end

  end

end
