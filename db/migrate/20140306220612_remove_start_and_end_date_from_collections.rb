class RemoveStartAndEndDateFromCollections < ActiveRecord::Migration
  def change
    remove_columns :collections, :start_date, :end_date
  end
end
