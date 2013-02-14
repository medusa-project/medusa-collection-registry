module AssessmentsHelper

  def storage_media_select_collection
    StorageMedium.all.collect do |medium|
      [medium.name, medium.id]
    end
  end

end
