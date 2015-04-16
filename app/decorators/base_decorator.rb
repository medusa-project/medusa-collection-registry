class BaseDecorator < Draper::Decorator
  delegate_all

  def decorated_class
    object.class
  end

  def decorated_class_human
    decorated_class.to_s.underscore.humanize
  end

  def decorated_class_plural_underscore
    decorated_class.to_s.pluralize.underscore
  end

end