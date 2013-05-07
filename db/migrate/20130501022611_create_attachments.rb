class CreateAttachments < ActiveRecord::Migration
  def change
  	create_table :attachments do |t|
		t.integer :attachable_id
		t.string :attachable_type, :index => true
		t.string :attachment_file_name
		t.string :attachment_content_type
		t.integer :attachment_file_size
		t.integer :author_id
		t.text :description
		t.timestamps
    end
  end
end
