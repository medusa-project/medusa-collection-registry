json.repositories(Repository.all) do |repository|
  json.(repository, :id, :uuid, :title, :url, :notes, :address_1, :address_2, :city, :state, :zip, :phone_number,
        :email, :contact_email, :ldap_admin_group)
end