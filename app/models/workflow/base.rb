class Workflow::Base < Job::Base

  self.abstract_class = true

  def put_in_queue(opts = {})
    Delayed::Job.enqueue(self, opts.reverse_merge(priority: 30))
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

  def be_in_state_and_requeue(state, opts = {})
    transaction do
      be_in_state(state)
      put_in_queue(opts)
    end
  end

  def be_in_state(state)
    transaction do
      self.state = state
      save!
    end
  end

  def be_at_end
    be_in_state_and_requeue('end')
  end

  def unrunnable_state
    raise RuntimeError, "Job cannot be run from state #{self.state}. The state must be changed externally."
  end

end