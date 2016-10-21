json.cache!(@collection) do
  json.(@collection, :id, :uuid, :title, :description, :description_html, :access_url,
      :publish, :representative_image, :representative_item, :repository_title, :child_collection_ids, :parent_collection_ids)
  json.repository_path repository_path(@collection.repository)
  json.file_groups @collection.file_groups.order(:id), partial: 'file_groups/show_related', as: :file_group
  json.resource_types @collection.resource_types, :name
  json.access_systems @collection.access_systems, :name, :service_owner, :application_manager
  json.rights @collection.rights_declaration, :rights_basis, :copyright_jurisdiction, :copyright_statement,
              :custom_copyright_statement, :access_restrictions
end
