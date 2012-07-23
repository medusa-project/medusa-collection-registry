class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :title
      t.string :url
      t.text :notes

      t.timestamps
    end
  end
end
