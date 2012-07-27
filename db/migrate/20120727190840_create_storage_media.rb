class CreateStorageMedia < ActiveRecord::Migration
  def change
    create_table :storage_media do |t|
      t.string :name
      t.timestamps
    end
  end
end
