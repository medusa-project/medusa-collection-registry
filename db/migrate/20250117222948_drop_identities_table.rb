class DropIdentitiesTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :identities, if_exists: true
  end

  def down
    create_table :identities do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :identities, :email, unique: true
  end
end
