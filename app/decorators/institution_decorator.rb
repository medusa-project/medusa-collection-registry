class InstitutionDecorator < BaseDecorator

  def label
    object.name
  end

  def events_path(args = {})
    nil
  end

end