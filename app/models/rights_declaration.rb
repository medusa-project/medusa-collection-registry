class RightsDeclaration < ActiveRecord::Base
  belongs_to :rights_attachable, :polymorphic => true
  attr_accessible :rights_basis, :copyright_jurisdiction, :copyright_statement, :access_restrictions
  before_validation :set_defaults
  cattr_accessor :rights_bases, :default_rights_basis, :copyright_jurisdictions, :default_copyright_jurisdiction,
                 :copyright_statements, :default_copyright_statement, :access_restrictions,
                 :default_access_restrictions, :instance_accessor => false

  #initialization - called when loading class
  def self.load_rights_data
    self.rights_bases = %w(copyright statute license other)
    self.default_rights_basis = 'copyright'
    self.copyright_jurisdictions = {'us' => 'United States',
                                    'xxc' => 'Canada'}
    self.default_copyright_jurisdiction = 'us'
    self.copyright_statements ={'pd' => 'Public domain.',
                                'us' => 'Public domain. U.S. Government document.'}
    self.default_copyright_statement = 'pd'
    self.access_restrictions = {'DISSEMINATE' => 'Access is open and unrestricted.',
                                'DISSEMINATE/DISALLOW' => 'Access is restricted.'}
    self.default_access_restrictions = 'DISSEMINATE/DISALLOW'
  end

  load_rights_data

  def set_defaults
    self.rights_basis ||= self.class.default_rights_basis
    self.copyright_jurisdiction ||= self.class.default_copyright_jurisdiction
    self.access_restrictions ||= self.class.default_access_restrictions
  end

  validates_inclusion_of :rights_basis, :in => self.rights_bases
  validates_inclusion_of :copyright_jurisdiction, :in => self.copyright_jurisdictions.keys
  validates_inclusion_of :copyright_statement, :in => self.copyright_statements.keys, :allow_blank => true
  validates_inclusion_of :access_restrictions, :in => self.access_restrictions.keys

  def copyright_jurisdiction_text
    self.class.copyright_jurisdictions[self.copyright_jurisdiction]
  end

  def copyright_statement_text
    self.class.copyright_statements[self.copyright_statement]
  end

  def access_restrictions_text
    self.class.access_restrictions[self.access_restrictions]
  end

end
