class CreateWorkflowIngests < ActiveRecord::Migration
  def change
    create_table :workflow_ingests do |t|
      t.string :state
      t.references :external_file_group, index: true
      t.references :bit_level_file_group, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
