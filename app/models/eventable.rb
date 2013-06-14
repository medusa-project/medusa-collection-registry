module Eventable
  def supported_event_hash
    raise RuntimeError, 'Responsibility of including class'
  end

  def supported_event_keys
    self.supported_event_hash.keys
  end

  def event_message(key)
    self.supported_event_hash[key]
  end

  def read_event_hash(group_key)
    YAML.load_file(File.join(Rails.root, 'config', 'events.yml'))[group_key.to_s]
  end

  def event_select_options
    self.supported_event_hash.invert
  end

end