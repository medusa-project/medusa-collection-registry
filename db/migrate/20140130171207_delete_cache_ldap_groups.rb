class DeleteCacheLdapGroups < ActiveRecord::Migration
  def up
    drop_table :cache_ldap_groups
  end

  def down
    create_table :cache_ldap_groups do |t|
      t.integer :user_id
      t.string :group
      t.string :domain
      t.boolean :member

      t.timestamps
    end
    add_index :cache_ldap_groups, :user_id
    add_index :cache_ldap_groups, :created_at
  end
end
