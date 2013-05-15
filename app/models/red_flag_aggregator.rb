#Mix this in to an ActiveRecord::Base subclass and use aggregates_red_flags to specify how to accumulate
#red flags for a member of that class.
#The all_red_flags method is defined automatically and accumulates red flags as specified by the :self and
#:collections options.
#The :self option takes a symbol or array of symbols. Each of these  methods is called on the object to
#get a list of red flags.
#The :collections option takes a symbol or array of symbols. Each of these methods is called on the object to
#get a collection of other objects - for each of these objects :all_red_flags is called (if it is understood)
#and the returned red flags are accumulated
#The :label_method option specifies a method to send to the object to get a link label (to go back from the red flag
# table to the object.)
#The :path_method option specifies a path_helper method used to construct the url back to the object (this is
# needed to accomodate file group STI)

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
      @red_flag_aggregator_label_method = opts[:label_method]
      @red_flag_aggregator_path_method = opts[:path_method]
    end

    def red_flag_methods
      (@red_flag_methods || []) + self.superclass.method_value_or_default(:red_flag_methods, [])
    end

    def red_flag_child_collections
      (@red_flag_child_collections || []) + self.superclass.method_value_or_default(:red_flag_child_collections, [])
    end

    def red_flag_aggregator_label_method
      @red_flag_aggregator_label_method or super
    end

    def red_flag_aggregator_path_method
      @red_flag_aggregator_path_method or super
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

    def red_flag_aggregator_label
      self.send(self.class.red_flag_aggregator_label_method)
    end

    def red_flag_aggregator_path_method
      self.class.red_flag_aggregator_path_method
    end

  end
end