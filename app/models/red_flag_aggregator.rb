module RedFlagAggregator

  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
  end

  #TODO - I'm not sure how this will work with FileGroup STI, but at some point we may find out.
  #If it doesn't work correctly then fix it.
  module ClassMethods
    def aggregates_red_flags(opts = {})
      @red_flag_methods = Array.wrap(opts[:self] || [])
      @red_flag_child_collections = Array.wrap(opts[:collections] || [])
    end

    def red_flag_methods
      (@red_flag_methods || []) + self.superclass.method_value_or_default(:red_flag_methods, [])
    end

    def red_flag_child_collections
      (@red_flag_child_collections || []) + self.superclass.method_value_or_default(:red_flag_child_collections, [])
    end
  end

  module InstanceMethods
    def all_red_flags
      red_flags = Array.new
      self.class.red_flag_methods.each do |method|
        red_flags = red_flags + self.send(method)
      end
      self.class.red_flag_child_collections.each do |child|
        collection = self.send(child)
        collection.each do |member|
          red_flags = red_flags + member.method_value_or_default(:all_red_flags, [])
        end
      end
      red_flags.uniq.sort { |a, b| b.created_at <=> a.created_at }
    end
  end
end