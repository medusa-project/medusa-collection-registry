class RightsDeclaration < ActiveRecord::Base
  belongs_to :rights_attachable, :polymorphic => true
  attr_accessible :rights_basis, :copyright_jurisdiction, :copyright_statement, :access_restrictions
  before_validation :set_defaults
  cattr_accessor :rights_bases, :default_rights_basis, :copyright_jurisdictions, :default_copyright_jurisdiction,
                 :copyright_statements, :default_copyright_statement, :access_restrictions,
                 :default_access_restrictions, :instance_accessor => false

  #initialization
  def self.load_rights_data
    rights_yaml = YAML.load_file(File.join(Rails.root, 'config', 'rights_fields.yml'))
    %w(rights_bases default_rights_basis copyright_jurisdictions default_copyright_jurisdiction
copyright_statements default_copyright_statement access_restrictions default_access_restrictions).each do |field|
      self.send("#{field}=", rights_yaml[field])
    end
  end

  #we need to call this as we're loading the class so that the validations for inclusion will work properly
  load_rights_data

  def set_defaults
    self.rights_basis ||= self.class.default_rights_basis
    self.copyright_jurisdiction ||= self.class.default_copyright_jurisdiction
    self.access_restrictions ||= self.class.default_access_restrictions
  end

  validates_inclusion_of :rights_basis, :in => Proc.new{self.rights_bases}
  validates_inclusion_of :copyright_jurisdiction, :in => Proc.new{self.copyright_jurisdictions.keys}
  validates_inclusion_of :copyright_statement, :in => Proc.new{self.copyright_statements.keys}, :allow_blank => true
  validates_inclusion_of :access_restrictions, :in => Proc.new{self.access_restrictions.keys}

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
