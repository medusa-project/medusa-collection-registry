json.cache!(@collection) do
  json.(@collection, :id, :uuid, :title, :description, :description_html, :access_url,
      :publish, :published_in_dls, :representative_image, :representative_item)
  json.file_groups @collection.file_groups.order(:id), partial: 'file_groups/show_related', as: :file_group
end
