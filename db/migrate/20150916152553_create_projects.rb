class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :manager_id, null: false
      t.integer :owner_id, null: false
      t.date :start_date, null: false
      t.string :status, null: false
      t.string :title, null: false
      t.text :specifications
      t.text :summary
    end
  end
end
