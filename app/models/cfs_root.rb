require 'singleton'
class CfsRoot
  include Singleton

  attr_accessor :path, :config

  def initialize
    self.config = MedusaRails3::Application.medusa_config['cfs']
    self.path = config['root']
  end

end