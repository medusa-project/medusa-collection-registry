#This used to apply to both collections and file groups, though the latter has been removed, so it
# might make sense to move this entirely into collection.
require 'active_support/concern'

module ResourceTypeable
  extend ActiveSupport::Concern

  included do
    has_many :resource_typeable_resource_type_joins, dependent: :destroy, as: :resource_typeable
    has_many :resource_types, -> {order(:name)}, through: :resource_typeable_resource_type_joins
  end

  def resource_type_names
    self.resource_types.collect(&:name).join('; ')
  end

  def resource_types_to_mods(xml)
    self.resource_types.each do |resource_type|
      xml.typeOfResource(resource_type.name, collection: 'yes')
    end
  end

end