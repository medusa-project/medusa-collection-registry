json.(@collection, :id, :uuid, :title)
json.file_groups @collection.file_groups, partial: 'file_groups/show_related', as: :file_group
