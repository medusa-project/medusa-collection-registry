# frozen_string_literal: true
#
require 'singleton'

class GroupManager
  include Singleton

  attr_accessor :resolver

  def initialize
    if Rails.env.production? || Rails.env.demo?
      self.resolver = GroupResolver::Ad.new
    else
      self.resolver = GroupResolver::Test.new
    end
  end
end
