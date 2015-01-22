require 'active_support/concern'

module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, -> { order 'date DESC' }, as: :eventable, dependent: :destroy
    class_attribute :supported_event_hash
  end

  module ClassMethods
    def initialize_event_hash(config_key)
      self.supported_event_hash = read_event_hash(config_key)
    end

    def read_event_hash(group_key)
      YAML.load_file(File.join(Rails.root, 'config', 'events.yml'))[group_key.to_s]
    end
  end

  def supported_event_hash
    self.class.supported_event_hash
  end

  def supported_event_keys
    self.supported_event_hash.keys
  end

  def event_message(key)
    self.supported_event_hash[key]
  end

  def event_select_options
    self.supported_event_hash.invert
  end

end