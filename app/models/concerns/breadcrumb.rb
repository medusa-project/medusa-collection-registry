require 'active_support/concern'

module Breadcrumb
  extend ActiveSupport::Concern

  module ClassMethods
    def breadcrumbs(opts = {})
      @breadcrumb_parent_method = opts[:parent]
      @breadcrumb_label_method = opts[:label]
    end

    def breadcrumb_parent_method
      @breadcrumb_parent_method || self.superclass.try(:breadcrumb_parent_method)
    end

    def breadcrumb_label_method
      @breadcrumb_label_method || self.superclass.try(:breadcrumb_label_method) || :label
    end

  end

  def breadcrumbs
    method = self.class.breadcrumb_parent_method
    parents = method ? self.send(method).breadcrumbs : Array.new
    parents << self
  end

  def breadcrumb_label
    self.send(self.class.breadcrumb_label_method)
  end

end