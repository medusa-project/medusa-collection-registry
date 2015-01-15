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
    parents = if method and (direct_parent = self.send(method)) then
                direct_parent.breadcrumbs
              else
                Array.new
              end
    parents << self
  end

  def breadcrumb_label
    self.send(self.class.breadcrumb_label_method)
  end

end