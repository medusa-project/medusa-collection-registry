class MetadataHelper::Collection
  include ModsHelper
  
  attr_accessor :collection

  def initialize(collection)
    self.collection = collection
  end

  def to_mods
    with_mods_boilerplate do |xml|
      xml.titleInfo do
        xml.title collection.title
      end
      xml.identifier(collection.uuid, type: 'uuid')
      collection.resource_types_to_mods(xml)
      xml.abstract collection.description
      xml.location do
        xml.url(collection.access_url || '', access: 'object in context', usage: 'primary')
      end
      xml.originInfo do
        xml.publisher(collection.repository.title)
      end
    end
  end

end