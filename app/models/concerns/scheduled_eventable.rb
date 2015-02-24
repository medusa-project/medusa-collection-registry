require 'active_support/concern'
module ScheduledEventable
  extend ActiveSupport::Concern

  included do
    has_many :scheduled_events, -> { order 'action_date ASC' }, as: :scheduled_eventable, dependent: :destroy
    class_attribute :supported_scheduled_event_hash
    initialize_scheduled_event_hash(self.to_s.underscore)
  end

  module ClassMethods
    def initialize_scheduled_event_hash(config_key)
      self.supported_scheduled_event_hash = self.read_scheduled_event_hash(config_key)
    end

    def read_scheduled_event_hash(group_key)
      YAML.load_file(File.join(Rails.root, 'config', 'scheduled_events.yml'))[group_key.to_s]
    end
  end

  def supported_scheduled_event_hash
    self.class.supported_scheduled_event_hash
  end

  def supported_scheduled_event_keys
    self.supported_scheduled_event_hash.keys
  end

  def scheduled_event_message(key)
    self.supported_scheduled_event_hash[key]['message']
  end

  def normal_event_key(key)
    self.supported_scheduled_event_hash[key]['normal_event_key']
  end

  def scheduled_event_select_options
    self.supported_scheduled_event_hash.collect do |k,v|
      [v['message'], k]
    end
  end

  def incomplete_scheduled_events
    self.scheduled_events.where("state != 'completed'")
  end

end