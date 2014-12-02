require 'active_support/concern'
module ScheduledEventable
  extend ActiveSupport::Concern

  def supported_scheduled_event_hash
    raise RuntimeError, 'Responsibility of including class'
  end

  def supported_scheduled_event_keys
    self.supported_scheduled_event_hash.keys
  end

  def scheduled_event_message(key)
    self.supported_scheduled_event_hash[key]['message']
  end

  def read_scheduled_event_hash(group_key)
    YAML.load_file(File.join(Rails.root, 'config', 'scheduled_events.yml'))[group_key.to_s]
  end

  def normal_event_key(key)
    self.supported_scheduled_event_hash[key]['normal_event_key']
  end

  def scheduled_event_select_options
    self.supported_scheduled_event_hash.collect do |k,v|
      [v['message'], k]
    end
  end

end