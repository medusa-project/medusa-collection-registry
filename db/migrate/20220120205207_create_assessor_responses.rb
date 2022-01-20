class CreateAssessorResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :assessor_responses do |t|
      t.references :assessor_task, foreign_key: true
      t.string :subtask
      t.boolean :success
      t.text :content

      t.timestamps
    end
  end
end
