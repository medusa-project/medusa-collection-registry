json.cache!(@repository) do
  json.(@repository, :id, :title, :url, :contact_email, :email, :uuid, :ldap_admin_domain, :ldap_admin_group)
  json.collections @repository.collections.order(:id), partial: 'collections/show_related', as: :collection
end
