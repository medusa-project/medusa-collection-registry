class AddLanguageAndSubjectColumnsToBookTrackerItems < ActiveRecord::Migration[5.2]
  def change
    add_column :book_tracker_items, :language, :string
    add_column :book_tracker_items, :subject, :string
  end
end
