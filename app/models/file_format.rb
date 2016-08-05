class FileFormat < ActiveRecord::Base
  has_many :file_format_profiles
  has_many :file_format_notes, -> {order :created_at}
  has_many :file_format_normalization_paths, -> {order :created_at}
end
