# frozen_string_literal: true
#
require 'singleton'

class GroupManager
  include Singleton

  def resolver
    return GroupResolver::Ad.new if Rails.env.production?

    GroupResolver::Test.new
  end


end
