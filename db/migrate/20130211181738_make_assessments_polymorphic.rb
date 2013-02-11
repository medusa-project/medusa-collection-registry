#make things besides collections able to have assessments, while hooking all existing assessments up to their Collection
#properly for Rails polymorphic associations
class MakeAssessmentsPolymorphic < ActiveRecord::Migration
  def up
    rename_column :assessments, :collection_id, :assessable_id
    add_column :assessments, :assessable_type, :string, :index => true
    Assessment.update_all(:assessable_type => 'Collection')
  end

  def down
    rename_column :assessments, :assessable_id, :collection_id
  end
end
