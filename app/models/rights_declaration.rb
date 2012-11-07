class RightsDeclaration < ActiveRecord::Base
  belongs_to :rights_attachable, :polymorphic => true
  attr_accessible :rights_basis, :copyright_jurisdiction, :copyright_statement, :access_restrictions
  before_validation :set_defaults

  def set_defaults
    self.rights_basis ||= 'copyright'
    self.copyright_jurisdiction ||= 'us'
    self.access_restrictions ||= 'DISSEMINATE/DISALLOW'
  end

  def self.all_rights_bases
    %w(copyright statute license other)
  end

  def self.all_copyright_jurisdictions
    {'us' => 'United States',
     'xxc' => 'Canada'}
  end

  def self.all_copyright_statements
    {'pd' => 'Public domain.',
     'us' => 'Public domain. U.S. Government document.'}
  end

  def self.all_access_restrictions
    {'DISSEMINATE' => 'Access is open and unrestricted.',
     'DISSEMINATE/DISALLOW' => 'Access is restricted.'}
  end

  validates_inclusion_of :rights_basis, :in => self.all_rights_bases
  validates_inclusion_of :copyright_jurisdiction, :in => self.all_copyright_jurisdictions.keys
  validates_inclusion_of :copyright_statement, :in => self.all_copyright_statements.keys, :allow_blank => true
  validates_inclusion_of :access_restrictions, :in => self.all_access_restrictions.keys

  def copyright_jurisdiction_text
    self.class.all_copyright_jurisdictions[self.copyright_jurisdiction]
  end

  def copyright_statement_text
    self.class.all_copyright_statements[self.copyright_statement]
  end

  def access_restrictions_text
    self.class.all_access_restrictions[self.access_restrictions]
  end

end
