class RightsDeclaration < ActiveRecord::Base
  belongs_to :rights_attachable, :polymorphic => true
  attr_accessible :rights_basis
  before_validation :set_defaults

  RIGHTS_BASES = %w(copyright statute license other)
  validates_inclusion_of :rights_basis, :in => RIGHTS_BASES

  def set_defaults
    self.rights_basis ||= 'copyright'
  end

end
