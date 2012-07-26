class CreateProductionUnits < ActiveRecord::Migration
  def change
    create_table :production_units do |t|
      t.string :title
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone_number
      t.string :email
      t.string :url
      t.text :notes

      t.timestamps
    end
  end
end
