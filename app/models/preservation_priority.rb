class PreservationPriority < ActiveRecord::Base
 # attr_accessible :name, :priority

  def self.default
    self.where('priority > 0').order('priority asc').first || raise(RuntimeError, 'No available PreservationPriorities')
  end
end
