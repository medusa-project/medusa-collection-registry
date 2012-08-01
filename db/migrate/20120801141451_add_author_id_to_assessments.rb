class AddAuthorIdToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :author_id, :integer
    add_index :assessments, :author_id
  end
end
