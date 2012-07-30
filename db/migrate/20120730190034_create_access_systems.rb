class CreateAccessSystems < ActiveRecord::Migration
  def change
    create_table :access_systems do |t|
      t.string :name

      t.timestamps
    end
  end
end
