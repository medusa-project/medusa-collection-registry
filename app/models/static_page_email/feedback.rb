class StaticPageEmail::Feedback < StaticPageEmail::Base
  attr_accessor :feedback
  validates_presence_of :feedback

end