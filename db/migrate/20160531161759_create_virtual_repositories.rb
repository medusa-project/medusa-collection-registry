class CreateVirtualRepositories < ActiveRecord::Migration
  def change
    create_table :virtual_repositories do |t|
      t.string :title
      t.references :repository
      t.timestamps null: false
    end
  end
end
