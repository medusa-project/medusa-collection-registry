class CollectionDecorator < BaseDecorator

  def label
    object.title
  end

end