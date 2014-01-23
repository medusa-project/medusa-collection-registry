class AddLdapToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :ldap_admin_domain, :string
    add_column :repositories, :ldap_admin_group, :string
  end
end
