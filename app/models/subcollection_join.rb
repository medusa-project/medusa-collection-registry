class SubcollectionJoin < ApplicationRecord

  belongs_to :parent_collection, class_name: 'Collection', touch: true
  belongs_to :child_collection, class_name: 'Collection', touch: true

  validates_presence_of :parent_collection_id
  validates_presence_of :child_collection_id

  validates_each :child_collection_id do |record, attr, value|
    record.errors.add attr, 'Collection cannot be a child collection of itself' if value == record.parent_collection_id
    record.errors.add attr, 'Parent and child collection must be in the same repository' unless record.child_collection.repository == record.parent_collection.repository
  end

end