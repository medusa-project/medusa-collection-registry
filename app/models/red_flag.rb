class RedFlag < ActiveRecord::Base
  belongs_to :red_flaggable, polymorphic: true, touch: true

  delegate :repository, to: :red_flaggable

  PRIORITIES = %w(high medium low)
  STATUSES = %w(flagged unflagged)

  validates_inclusion_of :priority, in: PRIORITIES
  validates_inclusion_of :status, in: STATUSES

  before_validation :ensure_priority, :ensure_status
  after_create :maybe_cascade

  def ensure_priority
    self.priority ||= 'medium'
  end

  def ensure_status
    self.status ||= 'flagged'
  end

  def flagged?
    self.status == 'flagged'
  end

  def unflag!
    self.status = 'unflagged'
    self.save!
  end

  def maybe_cascade
    CascadedRedFlagJoin.find_or_create_by(cascaded_red_flaggable: self, red_flag_id: self.id)
    if red_flaggable.respond_to?(:cascade_red_flag)
      red_flaggable.cascade_red_flag(self)
    end
  end

  def self.rebuild_cascaded_red_flag_cache
    CascadedRedFlagJoin.delete_all
    self.find_each do |red_flag|
      red_flag.maybe_cascade
    end
  end

end
