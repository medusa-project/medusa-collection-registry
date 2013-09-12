class CreatePackageProfiles < ActiveRecord::Migration
  def change
    create_table :package_profiles do |t|
      t.string :name
      t.string :url
      t.text :notes

      t.timestamps
    end
  end
end
