class CreateGlobusTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :globus_tokens do |t|
      t.string :access_token
      t.integer :expires_in
      t.string :body

      t.timestamps
    end
  end
end
