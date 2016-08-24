#Note that we now label these in the interface as File Rendering Profiles, but
#we haven't changed the model name, etc.
class FileFormatProfile < ActiveRecord::Base

  STATUSES = %w(active inactive)
  validates_uniqueness_of :name, allow_blank: false
  validates :status, presence: true, inclusion: STATUSES

  has_many :file_format_profiles_content_types_joins, dependent: :destroy
  has_many :content_types, -> { order 'name asc' }, through: :file_format_profiles_content_types_joins
  has_many :file_format_profiles_file_extensions_joins, dependent: :destroy
  has_many :file_extensions, -> { order 'extension asc' }, through: :file_format_profiles_file_extensions_joins
  belongs_to :file_format

  default_scope { order(:name) }

  def self.active
    where(status: 'active')
  end

  def create_clone
    self.dup.tap do |clone|
      clone.name = clone.name + ' (new)'
      clone.save!
      clone.content_types = self.content_types
      clone.file_extensions = self.file_extensions
    end
  end

end
