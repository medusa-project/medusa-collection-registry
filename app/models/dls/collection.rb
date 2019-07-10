class Dls::Collection

  attr_accessor :medusa_collection

  def initialize(medusa_collection)
    self.medusa_collection = medusa_collection
  end

  def collection_url
    Settings.dls.base_url + "/collections/#{medusa_collection.uuid}"
  end

  def items_url
    collection_url + '/items'
  end

end