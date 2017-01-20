class CreateWorkflowProjectItemIngests < ActiveRecord::Migration
  def change
    create_table :workflow_project_item_ingests do |t|
      t.string :state, null: false
      t.references :project
      t.references :user

      t.timestamps null: false
    end
  end
end
