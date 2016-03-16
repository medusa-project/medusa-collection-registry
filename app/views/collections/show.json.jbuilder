json.cache!(@collection) do
  json.(@collection, :id, :uuid, :title, :description)
  json.file_groups @collection.file_groups.order(:id), partial: 'file_groups/show_related', as: :file_group
end