class RightsDeclaration < ActiveRecord::Base
  belongs_to :rights_attachable, :polymorphic => true
  attr_accessible :rights_basis
end
