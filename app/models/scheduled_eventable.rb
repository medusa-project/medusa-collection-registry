module ScheduledEventable
  def supported_scheduled_event_hash
    raise RuntimeError, 'Responsibility of including class'
  end

  def supported_scheduled_event_keys
    self.supported_scheduled_event_hash.keys
  end

  def scheduled_event_message(key)
    self.supported_scheduled_event_hash[key]
  end

  def read_scheduled_event_hash(group_key)
    YAML.load_file(File.join(Rails.root, 'config', 'scheduled_events.yml'))[group_key.to_s]
  end

end