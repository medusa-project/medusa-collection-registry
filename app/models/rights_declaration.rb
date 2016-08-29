class RightsDeclaration < ActiveRecord::Base
  belongs_to :rights_declarable, polymorphic: true, touch: true
  before_validation :set_defaults
  before_validation :maybe_clear_custom_copyright
  cattr_accessor :rights_bases, :default_rights_basis, :copyright_jurisdictions, :default_copyright_jurisdiction,
                 :copyright_statements, :default_copyright_statement, :access_restrictions,
                 :default_access_restrictions, instance_accessor: false

  #initialization of fields
  def self.load_rights_data
    rights_yaml = Settings.rights_fields.to_h
    %i(rights_bases default_rights_basis copyright_jurisdictions default_copyright_jurisdiction
copyright_statements default_copyright_statement access_restrictions default_access_restrictions).each do |field|
      value = rights_yaml[field]
      value = value.to_h.stringify_keys if value.is_a?(Config::Options)
      self.send("#{field}=", value)
    end
  end

  load_rights_data

  def set_defaults
    self.rights_basis ||= self.class.default_rights_basis
    self.copyright_jurisdiction ||= self.class.default_copyright_jurisdiction
    self.access_restrictions ||= self.class.default_access_restrictions
  end

  validates_inclusion_of :rights_basis, in: Proc.new { self.rights_bases }
  validates_inclusion_of :copyright_jurisdiction, in: Proc.new { self.copyright_jurisdictions.keys }
  validates_inclusion_of :copyright_statement, in: Proc.new { self.copyright_statements.keys }, allow_blank: true
  validates_inclusion_of :access_restrictions, in: Proc.new { self.access_restrictions.keys }
  validates_presence_of :custom_copyright_statement, if: ->(rights_declaration) { rights_declaration.custom_copyright? }
  validates_absence_of :custom_copyright_statement, unless: ->(rights_declaration) { rights_declaration.custom_copyright? }

  def copyright_jurisdiction_text
    self.class.copyright_jurisdictions[self.copyright_jurisdiction]
  end

  def copyright_statement_text
    self.class.copyright_statements[self.copyright_statement]
  end

  def access_restrictions_text
    self.class.access_restrictions[self.access_restrictions]
  end

  def self.custom_copyright_key
    'cus'
  end

  def custom_copyright?
    self.copyright_statement == self.class.custom_copyright_key
  end

  def maybe_clear_custom_copyright
    self.custom_copyright_statement = '' unless self.custom_copyright?
  end

end
