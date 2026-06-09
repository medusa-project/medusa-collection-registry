class AddPublicDescriptionToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :public_description, :text
  end
end
