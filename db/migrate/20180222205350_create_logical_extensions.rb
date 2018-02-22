class CreateLogicalExtensions < ActiveRecord::Migration[5.1]
  def change
    create_table :logical_extensions do |t|

      t.timestamps
    end
  end
end
