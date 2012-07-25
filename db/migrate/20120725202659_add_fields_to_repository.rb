class AddFieldsToRepository < ActiveRecord::Migration
  def change
    change_table :repositories do |t|
      t.column :address_1, :string
      t.column :address_2, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :phone_number, :string
      t.column :email, :string
    end
  end
end
