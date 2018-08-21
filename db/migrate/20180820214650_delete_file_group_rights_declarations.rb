class DeleteFileGroupRightsDeclarations < ActiveRecord::Migration[5.1]
  def change
    RightsDeclaration.where(rights_declarable_type: 'FileGroup').delete_all
  end
end
