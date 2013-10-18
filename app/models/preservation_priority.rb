class PreservationPriority < ActiveRecord::Base
  def self.default
    self.where('priority > 0').order('priority asc').first || raise(RuntimeError, 'No available PreservationPriorities')
  end
end
