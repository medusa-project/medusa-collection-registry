# frozen_string_literal: true

require 'singleton'

class GlobusRateManager
  include Singleton
  attr_accessor :call_timestamps
  attr_accessor :error_timestamps

  DURATION = 10.seconds
  MAX_CALLS_PER_DURATION = 190

  ERROR_TIMEOUT = 5.minutes

  def initialize
    self.call_timestamps = Array.new()
    self.error_timestamps = Array.new()
  end

  def add_call
    self.call_timestamps << Time.now.utc
  end

  def add_error
    self.call_timestamps << Time.now.utc
  end

  def remove_old_calls
    self.call_timestamps.each_with_index do |call_timestamp, i|
      self.call_timestamps.delete_at(i) if call_timestamp < (Time.now.utc - DURATION)
    end
  end

  def remove_old_errors
    self.call_timestamps.each_with_index do |call_timestamp, i|
      self.call_timestamps.delete_at(i) if call_timestamp < (Time.now.utc - ERROR_TIMEOUT)
    end
  end

  def num_calls_in_duration
    remove_old_calls
    self.call_timestamps.length
  end

  def too_soon?
    remove_old_errors
    num_calls_in_duration >= MAX_CALLS_PER_DURATION || self.error_timestamps.length.positive?
  end

end
