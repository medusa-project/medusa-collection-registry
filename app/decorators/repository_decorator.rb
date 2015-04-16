class RepositoryDecorator < BaseDecorator

  def label
    object.title
  end

end