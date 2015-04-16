class FileGroupDecorator < BaseDecorator

  def label
    object.title
  end

end