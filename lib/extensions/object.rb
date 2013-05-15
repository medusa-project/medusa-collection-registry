class Object
  #return response if self is blank and self otherwise
  def if_blank(response)
    self.blank? ? response : self
  end

  def method_value_or_default(method, default)
    self.respond_to?(method) ? self.send(method) : default
  end
end