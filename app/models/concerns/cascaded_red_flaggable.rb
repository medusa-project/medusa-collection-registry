#In conjunction with CascadedRedFlagJoin allows red flags from child objects to be associated with their ancestors,
#as defined by the parent option of cascades_red_flags. C.f. CascadedEventable
require 'active_support/concern'

module CascadedRedFlaggable
  extend ActiveSupport::Concern

  included do
    has_many :cascaded_red_flag_joins, as: :cascaded_red_flaggable, dependent: :destroy
    has_many :cascaded_red_flags, -> {order 'created_at DESC'}, through: :cascaded_red_flag_joins, class_name: 'RedFlag', source: :red_flag
    class_attribute :cascade_red_flags_parent_method
  end

  module ClassMethods
    def cascades_red_flags(options = {})
      self.cascade_red_flags_parent_method = options[:parent] || nil
    end
  end

  def cascade_red_flag(red_flag)
    CascadedRedFlagJoin.find_or_create_by(cascaded_red_flaggable: self, red_flag_id: red_flag.id)
    if self.cascaded_red_flag_parent
      self.cascaded_red_flag_parent.cascade_red_flag(red_flag)
    end
  end

  def cascaded_red_flag_parent
    if parent_method = self.class.cascade_red_flags_parent_method
      self.send(parent_method)
    else
      nil
    end
  end

end