class AddFitsXmlToBitFiles < ActiveRecord::Migration
  def change
    add_column :bit_files, :fits_xml, :text
  end
end
