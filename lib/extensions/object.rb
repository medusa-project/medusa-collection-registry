class Object
  #return response if self is blank and self otherwise
  def if_blank(response)
    self.blank? ? response : self
  end

end