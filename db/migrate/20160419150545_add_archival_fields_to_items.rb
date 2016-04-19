class AddArchivalFieldsToItems < ActiveRecord::Migration
  def change
    add_column :items, :creator, :string
    add_column :items, :date, :date
    add_column :items, :rights_information, :text
  end
end
