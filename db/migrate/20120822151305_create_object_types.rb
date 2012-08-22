class CreateObjectTypes < ActiveRecord::Migration
  def change
    create_table :object_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
