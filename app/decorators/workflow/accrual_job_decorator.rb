class Workflow::AccrualJobDecorator < BaseDecorator

  #Note that this also detects whether the job is in a state requiring
  #approval in the first place - if not it's automatically not approvable.
  def approvable_by?(user)
    case state
      when 'initial_approval'
        h.safe_can?(:accrue, cfs_directory)
      when 'admin_approval'
        h.safe_can?(:accrue_overwrite, cfs_directory)
      else
        false
    end
  end

end