# The spec is either a string or an array of one or more strings. In the first case we just wrap to a one element array.
# The id is specified by the first element of the array.
# The second element is the title of the html element, with the first element being used if the second is absent. In the
# latter case it is normalized by being underscored and title cased.
# The third element is the font-awesome icon name. If absent then instead a string based on the title is used
class TabSpec

  attr_accessor :id, :label, :icon

  def initialize(spec)
    spec = Array.wrap(spec)
    self.id = spec.first
    self.label = spec.second || self.id.underscore.titlecase
    self.icon = spec.third
  end

  def title
    self.label
  end

end