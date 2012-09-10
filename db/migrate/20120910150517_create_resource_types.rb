class CreateResourceTypes < ActiveRecord::Migration
  def change
    create_table :resource_types do |t|
      t.string :name, :index => true

      t.timestamps
    end
  end
end
