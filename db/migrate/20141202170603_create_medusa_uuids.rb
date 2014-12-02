class CreateMedusaUuids < ActiveRecord::Migration
  def up
    create_table :medusa_uuids do |t|
      t.string :uuid
      t.references :uuidable, polymorphic: true, index: true

      t.timestamps
    end
    add_index :medusa_uuids, :uuid, unique: true
    Collection.connection.execute("INSERT INTO medusa_uuids (uuid, uuidable_id, uuidable_type, created_at, updated_at)
      SELECT uuid, id, 'Collection', now(), now() FROM collections")
    MedusaUuid.all.each {|m| m.touch}
    remove_column :collections, :uuid
  end

  def down
    add_column :collections, :uuid, :string, unique: true
    Collection.all.each do |collection|
      uuid = MedusaUuid.find_by(uuidable_id: collection.id, uuidable_type: 'Collection')
      collection.uuid = uuid.uuid
      collection.save!
    end
    drop_table :medusa_uuids
  end
end
