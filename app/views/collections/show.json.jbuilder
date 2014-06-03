json.(@collection, :id, :uuid, :title)
json.file_groups @collection.file_groups do |file_group|
  json.partial! 'file_groups/show_related', file_group: file_group
end
