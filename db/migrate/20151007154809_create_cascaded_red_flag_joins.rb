class CreateCascadedRedFlagJoins < ActiveRecord::Migration
  def change
    create_table :cascaded_red_flag_joins do |t|
      t.references :cascaded_red_flaggable, polymorphic: true
      t.integer :red_flag_id
      t.timestamps
    end
    add_index :cascaded_red_flag_joins, :red_flag_id
    add_index :cascaded_red_flag_joins, [:cascaded_red_flaggable_type, :cascaded_red_flaggable_id, :red_flag_id],
              unique: true, name: :unique_cascaded_red_flags
    RedFlag.rebuild_cascaded_red_flag_cache
  end
end
