class MedusaUuidDecorator < BaseDecorator

  def search_uuid_link
    h.link_to(object.uuid, h.uuid_path(object))
  end

  def uuidable
    object.uuidable.decorate
  end

  def search_uuid_label
    h.link_to(uuidable.label, h.polymorphic_path(uuidable))
  end


end