# frozen_string_literal: true

require 'singleton'

class GlobusRateManager
  include Singleton
  attr_accessor :call_timestamps

  DURATION = 10.seconds
  MAX_CALLS_PER_DURATION = 190

  def initialize
    self.call_timestamps = Array.new()
  end

  def add_call
    self.call_timestamps << Time.current
  end

  def remove_old_calls
    self.call_timestamps.each_with_index do |call_timestamp, i|
      self.call_timestamps.delete_at(i) if call_timestamp < (Time.current - DURATION)
    end
  end

  def num_calls_in_duration
    remove_old_calls
    self.call_timestamps.length
  end

  def too_soon?
    num_calls_in_duration >= MAX_CALLS_PER_DURATION
  end

end
