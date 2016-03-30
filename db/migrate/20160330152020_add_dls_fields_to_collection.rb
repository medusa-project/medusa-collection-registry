class AddDlsFieldsToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :representative_item, :string, default: ''
    add_column :collections, :published_in_dls, :boolean, default: false, index: true
  end
end
