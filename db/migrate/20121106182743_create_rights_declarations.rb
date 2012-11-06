class CreateRightsDeclarations < ActiveRecord::Migration
  def change
    create_table :rights_declarations do |t|
      t.references :rights_declarable, :polymorphic => true
      t.string :rights_basis

      t.timestamps
    end
    add_index :rights_declarations, :rights_declarable_id
  end
end
