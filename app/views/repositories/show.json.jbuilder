json.cache!(@repository) do
  json.(@repository, :id, :title, :url, :contact_email, :email)
  json.collections @repository.collections.order(:id), partial: 'collections/show_related', as: :collection
end
