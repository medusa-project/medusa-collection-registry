json.(@collection, :id, :uuid, :title)
json.file_groups @collection.file_groups.order(:id), partial: 'file_groups/show_related', as: :file_group
