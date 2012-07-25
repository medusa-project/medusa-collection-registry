class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.date :date
      t.text :preservation_risks
      t.text :notes
      t.integer :collection_id

      t.timestamps
    end
  end
end
