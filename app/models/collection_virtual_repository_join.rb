class CollectionVirtualRepositoryJoin < ActiveRecord::Base
  belongs_to :collection
  belongs_to :virtual_repository

  validates_uniqueness_of :collection_id, scope: :virtual_repository_id
  validates_presence_of :collection_id, :virtual_repository_id
end
