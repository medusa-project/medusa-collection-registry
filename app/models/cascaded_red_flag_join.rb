class CascadedRedFlagJoin < ApplicationRecord
  belongs_to :cascaded_red_flaggable, polymorphic: true
  belongs_to :red_flag

  validates_presence_of :red_flag_id, :cascaded_red_flaggable_id, :cascaded_red_flaggable_type

end