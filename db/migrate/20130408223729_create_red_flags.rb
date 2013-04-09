class CreateRedFlags < ActiveRecord::Migration
  def change
    create_table :red_flags do |t|
      t.integer :red_flaggable_id
      t.string :red_flaggable_type
      t.string :message

      t.timestamps
    end
    add_index :red_flags, :red_flaggable_id
    add_index :red_flags, :red_flaggable_type
  end
end
