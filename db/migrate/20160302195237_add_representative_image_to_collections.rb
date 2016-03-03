class AddRepresentativeImageToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :representative_image, :string, default: ''
  end
end
