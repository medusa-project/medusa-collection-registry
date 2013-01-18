class FileGroup < ActiveRecord::Base
  attr_accessible :collection_id, :file_format, :file_location, :total_file_size, :total_files,
                  :last_access_date, :producer_id, :storage_medium_id, :file_type_id, :summary, :provenance_note,
                  :collection_attributes, :naming_conventions, :directory_structure, :rights_declaration_attributes
  belongs_to :collection
  belongs_to :producer
  belongs_to :storage_medium
  belongs_to :file_type
  has_one :rights_declaration, :dependent => :destroy, :autosave => true, :as => :rights_declarable
  accepts_nested_attributes_for :collection, :rights_declaration

  before_validation :ensure_rights_declaration

  [:naming_conventions, :directory_structure].each do |field|
    auto_html_for field do
      html_escape
      link :target => "_blank"
      simple_format
    end
  end

  #note that this depends on our convention that the files are staged as /collection_id/file_group_id.
  def root_directory_id
    self.collection.root_directory.children.where(:name => self.id.to_s).first.id rescue nil
  end

  def file_type_name
    self.file_type.try(:name)
  end

  def storage_medium_name
    self.storage_medium.try(:name)
  end

  def ensure_rights_declaration
    self.rights_declaration ||= self.clone_collection_rights_declaration
  end

  def clone_collection_rights_declaration
    collection_rights = self.collection.rights_declaration
    self.build_rights_declaration(:rights_basis => collection_rights.rights_basis, :copyright_jurisdiction => collection_rights.copyright_jurisdiction,
                                  :copyright_statement => collection_rights.copyright_statement, :access_restrictions => collection_rights.access_restrictions)
  end

  def self.aggregate_size
    self.sum('total_file_size')
  end
end