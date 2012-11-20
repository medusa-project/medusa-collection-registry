#methods to interact with the handle server
#the including class should define handle and medusa_url methods which are needed by this
module RegistersHandle

  def ensure_handle
    with_handle_setup do |client|
      if client.exists?(self.handle)
        client.update_url(self.handle, self.medusa_url)
      else
        client.create_from_url(self.handle, self.medusa_url)
      end
    end
  end

  def remove_handle
    with_handle_setup do |client|
      if client.exists?(self.handle)
        client.delete(self.handle)
      end
    end
  end

  #define in including class - return desired handle of the object, or nil if that cannot be determined
  def handle
    raise RuntimeError, 'Subclass Responsibility'
  end

  #define in including class - return url of object in this system, or whatever url the handle server should use
  def medusa_url
    raise RuntimeError, 'Subclass Responsibility'
  end

  protected

  def with_handle_setup
    client = MedusaRails3::Application.handle_client
    if self.handle and client
      yield client
    end
  rescue Exception => e
    Rails.logger.error "Handle server error: #{e}"
  end

end