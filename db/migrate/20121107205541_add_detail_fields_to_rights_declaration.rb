class AddDetailFieldsToRightsDeclaration < ActiveRecord::Migration
  def change
    add_column :rights_declarations, :copyright_jurisdiction, :string
    add_column :rights_declarations, :copyright_statement, :string
    add_column :rights_declarations, :access_restrictions, :string
  end
end
