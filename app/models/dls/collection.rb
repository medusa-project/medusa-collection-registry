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

  def best_url
    #This is just so we can do these two in parallel, even though we might not need this one.
    collection_response_thread = Thread.new do
      HTTParty.head(collection_url, timeout: 3)
    end
    return items_url if HTTParty.head(items_url, timeout: 3).success?
    collection_response_thread.join
    collection_response = collection_response_thread.value
    #if the collection is there and public this should succeed; if there and not public then should
    # give an auth problem 403, and if not there I'm seeing a 500.
    return collection_url if (collection_response.success? or (403 == collection_response.code))
    return nil
  rescue
    return nil
  end

end