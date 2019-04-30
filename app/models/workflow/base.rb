#Whenever you need an outside class to do a state transform
#you should use the
#following pattern: Define a <state>_completed state and have the
#outside class use the complete_current_action method, which moves
#from <state> to <state>_completed and requeues. Then have the <state>_completed
#method transition to the next thing. This way outside classes don't
#need to know what is next in the workflow, just how to mark that
#something is done.

#The workflow should signal completion by putting itself in the 'end' state.
#At this point the success callback will run and destroy the job and any associated
#Delayed::Job. Note that this means that perform_end is not needed and if you do
#define it shouldn't do anything.

class Workflow::Base < Job::Base

  self.abstract_class = true

  def put_in_queue(opts = {})
    Delayed::Job.enqueue(self, opts.reverse_merge(priority: Settings.delayed_job.priority.base_job,
                                                  queue: queue))
  end

  def perform
    if runnable?
      self.send("perform_#{self.state}")
    else
      raise RuntimeError, "#{self.class}: #{id} unrunnable for unknown reason."
    end
  end

  #Override to use a different queue or even to change the queue depending on job status
  def queue
    Settings.delayed_job.default_queue
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

  def complete_current_action
    be_in_state_and_requeue(self.state + '_completed')
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

  def perform_end
    #no-op
  end

  def success(job)
    destroy_queued_jobs_and_self if self.state == 'end'
  end

end