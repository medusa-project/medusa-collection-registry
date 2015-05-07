class Workflow::Base < Job::Base

  self.abstract_class = true

  def put_in_queue
    Delayed::Job.enqueue(self, priority: 30)
  end

  def perform
    if runnable?
      self.send("perform_#{self.state}")
    else
      raise RuntimeError, "#{self.class}: #{id} unrunnable for unknown reason."
    end
  end

  #Override if something might change to make the job unrunnable. Preferably raise an error if it is.
  def runnable?
    true
  end

  def be_in_state_and_requeue(state)
    self.transaction do
      self.state = state
      save!
      put_in_queue
    end
  end

end