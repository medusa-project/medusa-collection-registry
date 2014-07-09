class AddUserIdToAmazonBackups < ActiveRecord::Migration
  def change
    add_column :amazon_backups, :user_id, :integer
  end
end
