class AddIngestedToItems < ActiveRecord::Migration
  def change
    add_column :items, :ingested, :boolean, default: false
  end
end
