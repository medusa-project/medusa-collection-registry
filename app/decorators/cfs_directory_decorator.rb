class CfsDirectoryDecorator < BaseDecorator

  def label
    object.path
  end

end