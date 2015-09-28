class AddCollectionReferenceToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :collection, index: true, foreign_key: true
  end
end
