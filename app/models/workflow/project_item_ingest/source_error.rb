class Workflow::ProjectItemIngest::SourceError < RuntimeError
  attr_accessor :key

  def initialize(key)
    self.key = key
  end
end