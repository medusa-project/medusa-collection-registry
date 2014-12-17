class AddServiceOwnerAndApplicationManagerToAccessSystems < ActiveRecord::Migration
  def change
    add_column :access_systems, :service_owner, :string
    add_column :access_systems, :application_manager, :string
  end
end
