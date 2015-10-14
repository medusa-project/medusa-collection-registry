class AddCustomCopyrightStatementToRightsDeclarations < ActiveRecord::Migration
  def change
    add_column :rights_declarations, :custom_copyright_statement, :text, default: ''
  end
end
