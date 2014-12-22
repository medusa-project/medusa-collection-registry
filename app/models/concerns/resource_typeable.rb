require 'active_support/concern'

module ResourceTypeable
  extend ActiveSupport::Concern

  included do
    has_many :resource_typeable_resource_type_joins, dependent: :destroy, as: :resource_typeable
    has_many :resource_types, through: :resource_typeable_resource_type_joins
  end

  def resource_type_names
    self.resource_types.collect(&:name).join('; ')
  end

end