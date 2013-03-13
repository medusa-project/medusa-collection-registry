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
end