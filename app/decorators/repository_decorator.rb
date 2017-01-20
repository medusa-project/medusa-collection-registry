class RepositoryDecorator < BaseDecorator

  def label
    object.title
  end

  def events_path(args = {})
    h.events_repository_path(object, args)
  end

end